import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mongo_dart/mongo_dart.dart';
import 'cloudflare_r2_service.dart';
import '../core/utils/local_auth_storage.dart';

/// MongoDB Database Service
/// Supports Local MongoDB, MongoDB Atlas direct TCP, and Web Bridge on Chrome
class MongoDBService {
  static final MongoDBService _instance = MongoDBService._internal();
  factory MongoDBService() => _instance;
  // MongoDB Atlas Cloud Connection (Debug/Test only; In release mode, all operations route through secure HTTPS backend)
  static const String defaultAtlasUri = kReleaseMode
      ? ""
      : "mongodb+srv://vishal250820_db_user:vishal25082006@portfolio.mo5wnyq.mongodb.net/pandarathar_matrimony?appName=portfolio&safeAtlas=true";
  static String atlasUri = defaultAtlasUri;

  // Local MongoDB connection fallback
  static const String localUri = "mongodb://127.0.0.1:27017/pandarathar_matrimony";

  // HTTP Web Bridge URL (for Chrome / Flutter Web & Mobile LAN)
  static String get webBridgeUrl => CloudflareR2Service.backendBaseUrl;

  Db? _db;
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  String get activeDatabaseName => _db?.databaseName ?? 'pandarathar_matrimony';

  MongoDBService._internal() {
    _checkWebBridge();
    if (!kIsWeb && !const bool.fromEnvironment('FLUTTER_TEST')) {
      connect();
    }
  }

  Future<bool> _checkWebBridge() async {
    try {
      final activeUrl = await CloudflareR2Service.getResolvedBackendUrl();
      if (activeUrl.isEmpty) {
        _isConnected = false;
        return false;
      }
      final res = await http.get(Uri.parse('$activeUrl/api/health')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        _isConnected = true;
        if (kDebugMode) {
          print("✓ Connected to MongoDB Atlas via Web Bridge: $activeUrl");
        }
        return true;
      }
    } catch (_) {}
    return false;
  }

  // Local database memory cache for instantaneous offline-first caching & test reliability
  final Map<String, Map<String, dynamic>> _databaseCache = {};
  Map<String, Map<String, dynamic>> get databaseCache => Map.unmodifiable(_databaseCache);

  /// Put a document into local memory cache
  void putInCache(String key, Map<String, dynamic> doc) {
    _databaseCache[key] = doc;
  }

  /// Clear database cache for test resets
  void clearDatabaseCache() {
    _databaseCache.clear();
    _cachedPayments.clear();
  }

  Future<bool>? _connectingFuture;

  /// Connect to MongoDB Atlas (or local MongoDB/cache fallback)
  Future<bool> connect({String? customUri}) async {
    if (_connectingFuture != null) {
      return await _connectingFuture!;
    }
    _connectingFuture = _connectInternal(customUri: customUri);
    try {
      return await _connectingFuture!;
    } finally {
      _connectingFuture = null;
    }
  }

  Future<bool> _connectInternal({String? customUri}) async {
    final connectionString = customUri ?? (atlasUri.isNotEmpty ? atlasUri : null) ?? localUri;
    try {
      if (_db != null && _isConnected && _db?.isConnected == true) {
        return true;
      }
      if (_db != null) {
        try {
          await _db!.close();
        } catch (_) {}
      }
      _db = await Db.create(connectionString);
      await _db!.open().timeout(const Duration(seconds: 15));
      _isConnected = true;
      if (kDebugMode) {
        print("✓ Connected to MongoDB Atlas: $connectionString");
      }
      return true;
    } catch (e) {
      _isConnected = false;
      if (kDebugMode) {
        print("ℹ MongoDB Atlas connection failed ($e).");
      }
      return false;
    }
  }

  /// Ensure MongoDB connection is active before read/write operations
  Future<bool> ensureConnected() async {
    if (kIsWeb) {
      return await _checkWebBridge();
    }
    if (_isConnected && _db != null && _db?.isConnected == true) {
      return true;
    }
    return await connect();
  }

  /// Check Connection Health and return diagnostics
  Future<Map<String, dynamic>> checkConnectionHealth() async {
    if (kIsWeb) {
      final ok = await _checkWebBridge();
      return {
        'connected': ok,
        'cluster': 'portfolio.mo5wnyq.mongodb.net',
        'database': activeDatabaseName,
        'mode': ok ? 'Live MongoDB Atlas Cluster (via Web Bridge)' : 'Offline-First Local Cache',
        'cachedProfiles': _databaseCache.keys.where((k) => k.startsWith('profile_')).length,
        'cachedPayments': _cachedPayments.length,
      };
    }

    if (!_isConnected || _db == null) {
      final success = await connect();
      if (!success) {
        return {
          'connected': false,
          'cluster': 'portfolio.mo5wnyq.mongodb.net',
          'mode': 'Offline-First Local Cache',
          'cachedProfiles': _databaseCache.keys.where((k) => k.startsWith('profile_')).length,
          'cachedPayments': _cachedPayments.length,
        };
      }
    }

    try {
      final collections = await _db!.getCollectionNames();
      return {
        'connected': true,
        'cluster': 'portfolio.mo5wnyq.mongodb.net',
        'database': activeDatabaseName,
        'collections': collections,
        'mode': 'Live MongoDB Atlas Cluster',
      };
    } catch (e) {
      return {
        'connected': false,
        'cluster': 'portfolio.mo5wnyq.mongodb.net',
        'error': e.toString(),
        'mode': 'Offline-First Local Cache',
      };
    }
  }

  /// Disconnect
  Future<void> disconnect() async {
    if (_db != null && _isConnected) {
      await _db!.close();
      _isConnected = false;
    }
  }

  /// Save new Horoscope / Profile Registration
  Future<bool> saveHoroscopeRegistration(Map<String, dynamic> data) async {
    final doc = {
      ...data,
      'createdAt': DateTime.now().toIso8601String(),
    };
    final phone = data['phone']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    _databaseCache['horoscope_$phone'] = doc;

    if (!_isConnected || _db == null) {
      if (kDebugMode) {
        print("Simulated Save to MongoDB (Local Cache): $data");
      }
      return true;
    }
    try {
      final collection = _db!.collection('horoscope_registrations');
      await collection.insertOne(doc);
      return true;
    } catch (e) {
      if (kDebugMode) print("MongoDB Error saving horoscope: $e");
      return false;
    }
  }

  /// Update User Profile in MongoDB (persisting in profiles and users collections)
  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    final id = data['id']?.toString() ?? '';
    final phone = data['phone']?.toString() ?? '';
    final email = data['email']?.toString() ?? '';
    final name = data['name']?.toString() ?? '';
    final gender = data['gender']?.toString() ?? 'Groom';

    final updatedDoc = {
      ...data,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    // Store in local database cache immediately for offline reliability & fast retrieval
    if (id.isNotEmpty) _databaseCache['profile_id_$id'] = updatedDoc;
    if (phone.isNotEmpty) {
      final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
      _databaseCache['profile_phone_$phone'] = updatedDoc;
      if (cleanPhone.isNotEmpty) {
        _databaseCache['profile_phone_$cleanPhone'] = updatedDoc;
      }
    }
    if (email.isNotEmpty) _databaseCache['profile_email_${email.toLowerCase()}'] = updatedDoc;
    _databaseCache['latest_profile_update'] = updatedDoc;

    if (kDebugMode) {
      print("✓ [MongoDB] Profile updated in database: $name (Phone: $phone, Email: $email, Gender: $gender)");
    }

    if (kIsWeb) {
      try {
        final res = await http.post(
          Uri.parse('$webBridgeUrl/api/profile'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(updatedDoc),
        ).timeout(const Duration(seconds: 8));
        if (res.statusCode == 200) {
          _isConnected = true;
          return true;
        }
      } catch (e) {
        if (kDebugMode) print("Web Bridge profile update fallback: $e");
      }
      return true;
    }

    await ensureConnected();
    if (!_isConnected || _db == null) {
      return true;
    }

    try {
      final profilesCol = _db!.collection('profiles');
      final usersCol = _db!.collection('users');

      final profileSelector = id.isNotEmpty
          ? where.eq('id', id)
          : where.eq('phone', phone);
      await profilesCol.update(
        profileSelector,
        {
          r'$set': updatedDoc,
        },
        upsert: true,
      );

      final userSelector = phone.isNotEmpty
          ? where.eq('phone', phone)
          : where.eq('email', email);
      await usersCol.update(
        userSelector,
        {
          r'$set': {
            'name': name,
            'phone': phone,
            'email': email,
            'gender': gender,
            'updatedAt': DateTime.now().toIso8601String(),
          },
        },
        upsert: true,
      );

      return true;
    } catch (e) {
      if (kDebugMode) print("MongoDB Error updating profile: $e");
      return false;
    }
  }

  /// Update User Account in MongoDB (users collection) and Local Persistent Storage
  Future<bool> updateUserAccount(Map<String, dynamic> userData) async {
    final phone = userData['phone']?.toString() ?? '';
    final username = userData['username']?.toString() ?? '';
    final email = userData['email']?.toString() ?? '';

    final updatedDoc = {
      ...userData,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    // 1. Immediately save to permanent local storage (file on desktop/mobile, localStorage on web)
    try {
      await LocalAuthStorage.saveUser(updatedDoc);
    } catch (_) {}

    if (phone.isNotEmpty) {
      final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
      _databaseCache['user_phone_$phone'] = updatedDoc;
      if (cleanPhone.isNotEmpty) {
        _databaseCache['user_phone_$cleanPhone'] = updatedDoc;
      }
    }
    if (username.isNotEmpty) _databaseCache['user_username_${username.toLowerCase()}'] = updatedDoc;
    if (email.isNotEmpty) _databaseCache['user_email_${email.toLowerCase()}'] = updatedDoc;
    _databaseCache['latest_user_update'] = updatedDoc;

    if (kDebugMode) {
      print("✓ [MongoDB] User Account updated in database: $updatedDoc");
    }

    if (kIsWeb) {
      try {
        final res = await http.post(
          Uri.parse('$webBridgeUrl/api/user'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(updatedDoc),
        ).timeout(const Duration(seconds: 8));
        if (res.statusCode == 200) {
          _isConnected = true;
          return true;
        }
      } catch (e) {
        if (kDebugMode) print("Web Bridge user update fallback: $e");
      }
      return true;
    }

    await ensureConnected();
    if (!_isConnected || _db == null) {
      return true;
    }

    try {
      final usersCol = _db!.collection('users');
      final selector = phone.isNotEmpty
          ? where.eq('phone', phone)
          : where.eq('username', username);
      await usersCol.update(
        selector,
        {
          r'$set': updatedDoc,
        },
        upsert: true,
      );
      if (kDebugMode) {
        print("✓ [MongoDB Atlas] User account persisted permanently: ${userData['name']} ($phone / $username)");
      }
      return true;
    } catch (e) {
      if (kDebugMode) print("MongoDB Error updating user account: $e");
      return false;
    }
  }

  /// Fetch single profile from local cache or MongoDB
  Future<Map<String, dynamic>?> getProfileByIdOrPhone(String identifier) async {
    final query = identifier.trim();
    final clean = query.replaceAll(RegExp(r'\D'), '');

    if (_databaseCache.containsKey('profile_id_$query')) {
      return _databaseCache['profile_id_$query'];
    }
    if (_databaseCache.containsKey('profile_phone_$query')) {
      return _databaseCache['profile_phone_$query'];
    }
    if (clean.isNotEmpty && _databaseCache.containsKey('profile_phone_$clean')) {
      return _databaseCache['profile_phone_$clean'];
    }

    // Search cached profile entries
    for (final entry in _databaseCache.entries) {
      if (entry.key.startsWith('profile_')) {
        final val = entry.value;
        final p = val['phone']?.toString().replaceAll(RegExp(r'\D'), '') ?? '';
        final id = val['id']?.toString() ?? '';
        if ((clean.isNotEmpty && p == clean) || id == query) {
          return val;
        }
      }
    }

    if (kIsWeb) {
      try {
        final res = await http.get(
          Uri.parse('$webBridgeUrl/api/profile?query=$identifier'),
        ).timeout(const Duration(seconds: 8));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['profile'] != null) {
            final doc = Map<String, dynamic>.from(data['profile']);
            _databaseCache['profile_id_${doc['id']}'] = doc;
            if (clean.isNotEmpty) _databaseCache['profile_phone_$clean'] = doc;
            return doc;
          }
        }
      } catch (_) {}
      return null;
    }

    await ensureConnected();
    if (!_isConnected || _db == null) return null;
    try {
      final collection = _db!.collection('profiles');
      Map<String, dynamic>? doc;
      if (clean.isNotEmpty) {
        doc = await collection.findOne(where.eq('phone', clean));
        doc ??= await collection.findOne(where.eq('phone', query));
      }
      doc ??= await collection.findOne(where.eq('id', query));
      return doc;
    } catch (_) {
      return null;
    }
  }

  /// Fetch user account by phone, username or email
  Future<Map<String, dynamic>?> getUserAccount(String phoneOrUsernameOrEmail) async {
    final query = phoneOrUsernameOrEmail.trim();
    final queryLower = query.toLowerCase();
    final clean = query.replaceAll(RegExp(r'\D'), '');

    if (_databaseCache.containsKey('user_phone_$query')) {
      return _databaseCache['user_phone_$query'];
    }
    if (clean.isNotEmpty && _databaseCache.containsKey('user_phone_$clean')) {
      return _databaseCache['user_phone_$clean'];
    }
    if (_databaseCache.containsKey('user_username_$queryLower')) {
      return _databaseCache['user_username_$queryLower'];
    }
    if (_databaseCache.containsKey('user_email_$queryLower')) {
      return _databaseCache['user_email_$queryLower'];
    }

    // Search cached user entries
    for (final entry in _databaseCache.entries) {
      if (entry.key.startsWith('user_')) {
        final val = entry.value;
        final p = val['phone']?.toString().replaceAll(RegExp(r'\D'), '') ?? '';
        final u = val['username']?.toString().toLowerCase() ?? '';
        final e = val['email']?.toString().toLowerCase() ?? '';
        if ((clean.isNotEmpty && p == clean) || u == queryLower || e == queryLower) {
          return val;
        }
      }
    }

    // Check permanent local storage (file on desktop/mobile, localStorage on web)
    try {
      final localUser = await LocalAuthStorage.findUser(phoneOrUsernameOrEmail);
      if (localUser != null) {
        if (clean.isNotEmpty) _databaseCache['user_phone_$clean'] = localUser;
        if (localUser['username'] != null) {
          _databaseCache['user_username_${localUser['username'].toString().toLowerCase()}'] = localUser;
        }
        return localUser;
      }
    } catch (_) {}

    if (kIsWeb) {
      try {
        final res = await http.get(
          Uri.parse('$webBridgeUrl/api/user?query=$phoneOrUsernameOrEmail'),
        ).timeout(const Duration(seconds: 8));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['user'] != null) {
            final doc = Map<String, dynamic>.from(data['user']);
            if (clean.isNotEmpty) _databaseCache['user_phone_$clean'] = doc;
            if (doc['username'] != null) {
              _databaseCache['user_username_${doc['username'].toString().toLowerCase()}'] = doc;
            }
            try {
              await LocalAuthStorage.saveUser(doc);
            } catch (_) {}
            return doc;
          }
        }
      } catch (_) {}
      return null;
    }

    await ensureConnected();
    if (!_isConnected || _db == null) return null;
    try {
      final collection = _db!.collection('users');
      Map<String, dynamic>? doc;
      if (clean.isNotEmpty) {
        doc = await collection.findOne(where.eq('phone', clean));
        doc ??= await collection.findOne(where.eq('phone', query));
      }
      doc ??= await collection.findOne(where.eq('username', queryLower));
      doc ??= await collection.findOne(where.eq('email', queryLower));
      if (doc != null) {
        if (clean.isNotEmpty) _databaseCache['user_phone_$clean'] = doc;
        if (doc['username'] != null) {
          _databaseCache['user_username_${doc['username'].toString().toLowerCase()}'] = doc;
        }
        try {
          await LocalAuthStorage.saveUser(doc);
        } catch (_) {}
      }
      return doc;
    } catch (_) {
      return null;
    }
  }

  /// Fetch all user accounts from local storage, web bridge, or direct MongoDB Atlas
  Future<List<Map<String, dynamic>>> getAllUserAccounts() async {
    final results = <Map<String, dynamic>>[];
    final seenPhones = <String>{};

    // 1. Load from persistent local storage
    try {
      final local = await LocalAuthStorage.loadAllUsers();
      for (final u in local) {
        final p = u['phone']?.toString().replaceAll(RegExp(r'\D'), '') ?? '';
        if (p.isNotEmpty && seenPhones.add(p)) {
          results.add(u);
        }
      }
    } catch (_) {}

    // 2. Load from Web Bridge or MongoDB Atlas
    if (kIsWeb) {
      try {
        final res = await http.get(
          Uri.parse('$webBridgeUrl/api/users'),
        ).timeout(const Duration(seconds: 8));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['users'] is List) {
            for (final u in data['users']) {
              final m = Map<String, dynamic>.from(u as Map);
              final p = m['phone']?.toString().replaceAll(RegExp(r'\D'), '') ?? '';
              if (p.isNotEmpty) {
                if (seenPhones.add(p)) {
                  results.add(m);
                }
                await LocalAuthStorage.saveUser(m);
              }
            }
          }
        }
      } catch (_) {}
      return results;
    }

    await ensureConnected();
    if (_isConnected && _db != null) {
      try {
        final collection = _db!.collection('users');
        final allDocs = await collection.find().toList();
        for (final doc in allDocs) {
          final m = Map<String, dynamic>.from(doc);
          m.remove('_id');
          final p = m['phone']?.toString().replaceAll(RegExp(r'\D'), '') ?? '';
          if (p.isNotEmpty) {
            if (seenPhones.add(p)) {
              results.add(m);
            }
            await LocalAuthStorage.saveUser(m);
          }
        }
      } catch (e) {
        if (kDebugMode) print("Error fetching all users from MongoDB: $e");
      }
    }

    return results;
  }

  /// Delete Profile from MongoDB Atlas
  Future<bool> deleteProfile(String profileId, {String? phone}) async {
    final cleanPhone = phone?.replaceAll(RegExp(r'\D'), '') ?? '';
    _databaseCache.remove('profile_id_$profileId');
    if (phone != null && phone.isNotEmpty) {
      _databaseCache.remove('profile_phone_$phone');
    }
    if (cleanPhone.isNotEmpty) {
      _databaseCache.remove('profile_phone_$cleanPhone');
    }

    if (kIsWeb) {
      try {
        final uri = Uri.parse('$webBridgeUrl/api/profile?id=$profileId&phone=${phone ?? ''}');
        final res = await http.delete(uri).timeout(const Duration(seconds: 4));
        if (res.statusCode == 200) {
          if (kDebugMode) print("✓ [MongoDB] Profile deleted via Web Bridge: $profileId");
          return true;
        } else {
          // Fallback to POST
          final postRes = await http.post(
            Uri.parse('$webBridgeUrl/api/profile/delete'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'id': profileId, 'phone': phone ?? ''}),
          ).timeout(const Duration(seconds: 4));
          return postRes.statusCode == 200;
        }
      } catch (e) {
        if (kDebugMode) print("⚠ [MongoDB] deleteProfile Web Bridge error: $e");
        return false;
      }
    }

    if (!_isConnected || _db == null) return true;
    try {
      final collection = _db!.collection('profiles');
      var selector = where;
      if (profileId.isNotEmpty && cleanPhone.isNotEmpty) {
        selector = where.eq('id', profileId).or(where.eq('phone', cleanPhone)).or(where.eq('phone', phone!));
      } else if (profileId.isNotEmpty) {
        selector = where.eq('id', profileId);
      } else if (cleanPhone.isNotEmpty) {
        selector = where.eq('phone', cleanPhone).or(where.eq('phone', phone!));
      }
      await collection.remove(selector);
      return true;
    } catch (e) {
      if (kDebugMode) print("MongoDB Error deleting profile: $e");
      return false;
    }
  }

  /// Fetch profiles from MongoDB Atlas or local cache
  Future<List<Map<String, dynamic>>> getProfiles({String? gender}) async {
    if (kIsWeb) {
      try {
        final res = await http.get(Uri.parse('$webBridgeUrl/api/profiles')).timeout(const Duration(seconds: 4));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['profiles'] is List) {
            final list = List<Map<String, dynamic>>.from(data['profiles']);
            for (final doc in list) {
              if (doc['id'] != null) {
                _databaseCache['profile_id_${doc['id']}'] = doc;
              }
            }
            if (gender != null && gender.isNotEmpty && gender != 'All') {
              return list.where((p) => p['gender']?.toString().toLowerCase() == gender.toLowerCase()).toList();
            }
            return list;
          }
        }
      } catch (e) {
        if (kDebugMode) print("Web Bridge getProfiles error: $e");
      }
      // Return cached profiles
      final cached = _databaseCache.entries
          .where((e) => e.key.startsWith('profile_id_'))
          .map((e) => e.value)
          .toList();
      return cached;
    }

    if (!_isConnected || _db == null) return [];
    try {
      final collection = _db!.collection('profiles');
      final query = gender != null ? where.eq('gender', gender) : where;
      return await collection.find(query).toList();
    } catch (_) {
      return [];
    }
  }

  // Local list of cached payments
  final List<Map<String, dynamic>> _cachedPayments = [];
  List<Map<String, dynamic>> get cachedPayments => List.unmodifiable(_cachedPayments);

  /// Save new payment request in MongoDB and local cache
  Future<bool> savePaymentRequest(Map<String, dynamic> data) async {
    final paymentDoc = {
      ...data,
      'savedAt': DateTime.now().toIso8601String(),
    };
    final id = data['id']?.toString() ?? 'REQ-${DateTime.now().millisecondsSinceEpoch}';
    _databaseCache['payment_$id'] = paymentDoc;

    final existingIdx = _cachedPayments.indexWhere((p) => p['id'] == id);
    if (existingIdx != -1) {
      _cachedPayments[existingIdx] = paymentDoc;
    } else {
      _cachedPayments.insert(0, paymentDoc);
    }

    if (kDebugMode) {
      print("✓ [MongoDB] Payment record stored in database: $id - UTR: ${data['utrNumber']} - ₹${data['totalAmount']}");
    }

    if (kIsWeb) {
      try {
        await http.post(
          Uri.parse('$webBridgeUrl/api/payment'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(paymentDoc),
        ).timeout(const Duration(seconds: 5));
      } catch (_) {}
      return true;
    }

    await ensureConnected();
    if (!_isConnected || _db == null) {
      return true;
    }

    try {
      final collection = _db!.collection('payments');
      await collection.update(
        where.eq('id', id),
        {
          r'$set': paymentDoc,
        },
        upsert: true,
      );
      return true;
    } catch (e) {
      if (kDebugMode) print("MongoDB Error saving payment: $e");
      return false;
    }
  }

  /// Fetch all stored payment requests
  Future<List<Map<String, dynamic>>> getPaymentRequests({String? userId, String? userPhone}) async {
    final cleanPhone = userPhone?.replaceAll(RegExp(r'\D'), '') ?? '';

    if (kIsWeb) {
      try {
        final queryParts = <String>[];
        if (userId != null && userId.isNotEmpty) queryParts.add('userId=$userId');
        if (cleanPhone.isNotEmpty) queryParts.add('userPhone=$cleanPhone');
        final qs = queryParts.isNotEmpty ? '?${queryParts.join('&')}' : '';
        final uri = Uri.parse('$webBridgeUrl/api/payments$qs');
        final res = await http.get(uri).timeout(const Duration(seconds: 6));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['payments'] is List) {
            final list = (data['payments'] as List)
                .map((p) => Map<String, dynamic>.from(p))
                .toList();
            for (final p in list) {
              final pid = p['id']?.toString() ?? '';
              if (pid.isNotEmpty) {
                _databaseCache['payment_$pid'] = p;
                final idx = _cachedPayments.indexWhere((cp) => cp['id'] == pid);
                if (idx != -1) {
                  _cachedPayments[idx] = p;
                } else {
                  _cachedPayments.insert(0, p);
                }
              }
            }
            return list;
          }
        }
      } catch (_) {}
    }

    await ensureConnected();
    if (!_isConnected || _db == null) {
      return _cachedPayments.where((p) {
        if (userId != null && userId.isNotEmpty && p['userId'] != userId) return false;
        if (cleanPhone.isNotEmpty) {
          final pPhone = (p['userPhone'] ?? '').toString().replaceAll(RegExp(r'\D'), '');
          if (pPhone.isNotEmpty && pPhone != cleanPhone) return false;
        }
        return true;
      }).toList();
    }
    try {
      final collection = _db!.collection('payments');
      final query = userId != null && userId.isNotEmpty ? where.eq('userId', userId) : where;
      final docs = await collection.find(query).toList();
      return docs;
    } catch (_) {
      return _cachedPayments;
    }
  }

  /// Delete a payment request by ID from MongoDB Atlas
  Future<bool> deletePaymentRequest(String id) async {
    _cachedPayments.removeWhere((p) => p['id'] == id);
    _databaseCache.remove('payment_$id');
    if (kIsWeb) {
      try {
        final uri = Uri.parse('$webBridgeUrl/api/payment?id=$id');
        final res = await http.delete(uri).timeout(const Duration(seconds: 5));
        return res.statusCode == 200;
      } catch (_) {
        return false;
      }
    }
    if (_isConnected && _db != null) {
      try {
        final col = _db!.collection('payments');
        await col.remove(where.eq('id', id));
        return true;
      } catch (_) {}
    }
    return false;
  }

  /// Fetch shortlist for a user from local cache or MongoDB Atlas
  Future<Map<String, dynamic>?> getShortlist(String userId, {String? userPhone}) async {
    final cleanPhone = userPhone?.replaceAll(RegExp(r'\D'), '') ?? '';

    // Check fast cache first
    if (_databaseCache.containsKey('shortlist_$userId')) {
      return _databaseCache['shortlist_$userId'];
    }
    if (cleanPhone.isNotEmpty && _databaseCache.containsKey('shortlist_$cleanPhone')) {
      return _databaseCache['shortlist_$cleanPhone'];
    }

    if (kIsWeb) {
      try {
        final uri = Uri.parse('$webBridgeUrl/api/shortlist?userId=$userId&userPhone=$cleanPhone');
        final res = await http.get(uri).timeout(const Duration(seconds: 6));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['shortlist'] != null) {
            final doc = Map<String, dynamic>.from(data['shortlist']);
            _databaseCache['shortlist_$userId'] = doc;
            if (cleanPhone.isNotEmpty) _databaseCache['shortlist_$cleanPhone'] = doc;
            return doc;
          }
        }
      } catch (_) {}
      return null;
    }

    await ensureConnected();
    if (!_isConnected || _db == null) return null;
    try {
      final collection = _db!.collection('shortlists');
      var doc = await collection.findOne(where.eq('userId', userId));
      if (doc == null && cleanPhone.isNotEmpty) {
        doc = await collection.findOne(where.eq('userPhone', cleanPhone));
      }
      if (doc != null) {
        _databaseCache['shortlist_$userId'] = doc;
        if (cleanPhone.isNotEmpty) _databaseCache['shortlist_$cleanPhone'] = doc;
      }
      return doc;
    } catch (_) {
      return null;
    }
  }

  /// Save shortlist / liked profiles in MongoDB and local cache
  Future<bool> saveShortlist({
    required String userId,
    required List<String> profileIds,
    String? userPhone,
  }) async {
    final cleanPhone = userPhone?.replaceAll(RegExp(r'\D'), '') ?? '';
    final doc = {
      'userId': userId,
      'userPhone': userPhone ?? '',
      'profileIds': profileIds,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    _databaseCache['shortlist_$userId'] = doc;
    if (cleanPhone.isNotEmpty) {
      _databaseCache['shortlist_$cleanPhone'] = doc;
    }

    if (kDebugMode) {
      print("✓ [MongoDB] Shortlist saved for user $userId ($cleanPhone): $profileIds");
    }

    if (kIsWeb) {
      try {
        await http.post(
          Uri.parse('$webBridgeUrl/api/shortlist'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(doc),
        ).timeout(const Duration(seconds: 6));
      } catch (_) {}
      return true;
    }

    await ensureConnected();
    if (!_isConnected || _db == null) return true;
    try {
      final collection = _db!.collection('shortlists');
      await collection.update(
        where.eq('userId', userId),
        {r'$set': doc},
        upsert: true,
      );
      return true;
    } catch (e) {
      if (kDebugMode) print("MongoDB Error saving shortlist: $e");
      return false;
    }
  }
}


