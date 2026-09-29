import 'package:flutter/foundation.dart';
import 'mongodb_service.dart';
import 'cloudflare_r2_service.dart';

class UserAccount {
  final String name;
  final String username;
  final String phone;
  final String email;
  final String password;
  final String gender;
  final DateTime registeredAt;
  final Uint8List? imageBytes;
  final String? profileImageUrl;

  UserAccount({
    required this.name,
    required this.username,
    required this.phone,
    this.email = '',
    required this.password,
    this.gender = 'Groom',
    DateTime? registeredAt,
    this.imageBytes,
    this.profileImageUrl,
  }) : registeredAt = registeredAt ?? DateTime.now();

  UserAccount copyWith({
    String? name,
    String? username,
    String? phone,
    String? email,
    String? password,
    String? gender,
    DateTime? registeredAt,
    Uint8List? imageBytes,
    String? profileImageUrl,
  }) {
    return UserAccount(
      name: name ?? this.name,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      gender: gender ?? this.gender,
      registeredAt: registeredAt ?? this.registeredAt,
      imageBytes: imageBytes ?? this.imageBytes,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'phone': phone,
      'email': email,
      'password': password,
      'gender': gender,
      'hasCustomImage': imageBytes != null || (profileImageUrl != null && profileImageUrl!.isNotEmpty),
      'profileImageUrl': profileImageUrl,
      'registeredAt': registeredAt.toIso8601String(),
    };
  }

  factory UserAccount.fromMap(Map<String, dynamic> map) {
    final rawImg = map['profileImageUrl']?.toString() ?? map['r2ProfileImageUrl']?.toString();
    return UserAccount(
      name: map['name']?.toString() ?? '',
      username: map['username']?.toString() ?? map['phone']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      gender: map['gender']?.toString() ?? 'Groom',
      registeredAt: map['registeredAt'] != null
          ? DateTime.tryParse(map['registeredAt'].toString())
          : null,
      profileImageUrl: (rawImg != null && rawImg.isNotEmpty)
          ? CloudflareR2Service().ensureDisplayableUrl(rawImg)
          : null,
    );
  }
}


class AuthResult {
  final bool success;
  final String message;
  final UserAccount? user;

  const AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserAccount? _currentUser;
  UserAccount? get currentUser => _currentUser;
  UserAccount? get currentUserAccount => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Registered Accounts store (pre-populated with demo accounts)
  final List<UserAccount> _users = [
    UserAccount(
      name: "Karthik Sundaram",
      username: "demo",
      phone: "9876543210",
      email: "demo@pandarathar.com",
      password: "password123",
      gender: "Groom",
    ),
    UserAccount(
      name: "Soundarya R.",
      username: "soundarya",
      phone: "9876501234",
      email: "soundarya@pandarathar.com",
      password: "password123",
      gender: "Bride",
    ),
    UserAccount(
      name: "Vishal",
      username: "vishal",
      phone: "6381180488",
      email: "vishal@pandarathar.com",
      password: "password123",
      gender: "Groom",
    ),
  ];

  List<UserAccount> get users => List.unmodifiable(_users);

  /// Check if a 10-digit phone number is already registered to an account
  bool isPhoneRegistered(String phone) {
    final cleanPhone = phone.trim().replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.isEmpty) return false;
    if (_users.any((u) => u.phone.replaceAll(RegExp(r'\D'), '') == cleanPhone)) {
      return true;
    }
    // Also check MongoDB database cache
    final cache = MongoDBService().databaseCache;
    return cache.containsKey('user_phone_$cleanPhone') || cache.containsKey('user_phone_$phone');
  }

  /// Check if an email is already registered to an account
  bool isEmailRegistered(String email) {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return false;
    if (_users.any((u) => u.email.trim().toLowerCase() == cleanEmail)) {
      return true;
    }
    // Also check MongoDB database cache
    final cache = MongoDBService().databaseCache;
    return cache.containsKey('user_email_$cleanEmail');
  }

  /// Authenticate with Username/Phone/Email and Password against in-memory & MongoDB database
  Future<AuthResult> login(String credential, String password) async {
    final trimmedCred = credential.trim();
    final trimmedCredLower = trimmedCred.toLowerCase();
    final cleanPhone = trimmedCred.replaceAll(RegExp(r'\D'), '');
    final tenDigitPhone = cleanPhone.length == 10
        ? cleanPhone
        : (cleanPhone.length == 12 && cleanPhone.startsWith('91')
            ? cleanPhone.substring(2)
            : (cleanPhone.length == 11 && cleanPhone.startsWith('0')
                ? cleanPhone.substring(1)
                : (cleanPhone.length == 11 ? cleanPhone.substring(0, 10) : '')));
    final trimmedPass = password.trim();

    if (trimmedCredLower == 'admin') {
      return const AuthResult(
        success: false,
        message: "நிர்வாகி உள்நுழைவு தடைசெய்யப்பட்டுள்ளது / Admin login not permitted",
      );
    }

    if (trimmedCred.isEmpty) {
      return const AuthResult(
        success: false,
        message: "பயனர் பெயர், கைபேசி எண் அல்லது மின்னஞ்சலை உள்ளிடவும் / Please enter username, mobile number or email",
      );
    }

    if (trimmedPass.isEmpty) {
      return const AuthResult(
        success: false,
        message: "கடவுச்சொல்லை உள்ளிடவும் / Please enter your password",
      );
    }

    // 1. Instant Fast-Path: Check in-memory registered accounts
    UserAccount? matchedUser;
    for (final u in _users) {
      final uClean = u.phone.replaceAll(RegExp(r'\D'), '');
      final isMatch = u.username.toLowerCase() == trimmedCredLower ||
          u.phone == trimmedCred ||
          (cleanPhone.isNotEmpty && uClean == cleanPhone) ||
          (tenDigitPhone.isNotEmpty && uClean == tenDigitPhone) ||
          (u.email.isNotEmpty && u.email.toLowerCase() == trimmedCredLower);
      if (isMatch) {
        matchedUser = u;
        break;
      }
    }

    if (matchedUser != null) {
      if (matchedUser.password == trimmedPass) {
        // Fast-path: Check database cache synchronously first (0ms)
        final cache = MongoDBService().databaseCache;
        Map<String, dynamic>? cachedUser = cache['user_phone_$trimmedCred'] ??
            (cleanPhone.isNotEmpty ? cache['user_phone_$cleanPhone'] : null) ??
            (tenDigitPhone.isNotEmpty ? cache['user_phone_$tenDigitPhone'] : null) ??
            cache['user_username_$trimmedCredLower'] ??
            cache['user_email_$trimmedCredLower'];

        try {
          cachedUser ??= await MongoDBService().getUserAccount(tenDigitPhone.isNotEmpty ? tenDigitPhone : trimmedCred);
        } catch (_) {}

        if (cachedUser != null) {
          final rawImg = cachedUser['profileImageUrl']?.toString() ?? cachedUser['r2ProfileImageUrl']?.toString();
          if (rawImg != null && rawImg.isNotEmpty) {
            matchedUser = matchedUser.copyWith(
              profileImageUrl: CloudflareR2Service().ensureDisplayableUrl(rawImg),
            );
          }
        }

        _currentUser = matchedUser;
        notifyListeners();
        return AuthResult(
          success: true,
          message: "வெற்றிகரமாக உள்நுழைந்துள்ளீர்கள்! / Login Successful!",
          user: matchedUser,
        );
      } else {
        return const AuthResult(
          success: false,
          message: "தவறான கடவுச்சொல்! / Incorrect password. Please try again.",
        );
      }
    }

    // 2. Fast-Path: Check databaseCache for stored credentials before making any network call
    final cache = MongoDBService().databaseCache;
    Map<String, dynamic>? dbUser = cache['user_phone_$trimmedCred'] ??
        (cleanPhone.isNotEmpty ? cache['user_phone_$cleanPhone'] : null) ??
        (tenDigitPhone.isNotEmpty ? cache['user_phone_$tenDigitPhone'] : null) ??
        cache['user_username_$trimmedCredLower'] ??
        cache['user_email_$trimmedCredLower'];

    // 3. If not in memory or cache, query MongoDB database via bridge
    if (dbUser == null) {
      try {
        final lookupQuery = tenDigitPhone.isNotEmpty ? tenDigitPhone : trimmedCred;
        dbUser = await MongoDBService().getUserAccount(lookupQuery);
      } catch (_) {}
    }

    if (dbUser != null) {
      final storedPass = dbUser['password']?.toString() ?? '';
      if (storedPass.isNotEmpty && storedPass == trimmedPass) {
        final account = UserAccount.fromMap(dbUser);
        _currentUser = account;
        // Add or update in local cache list
        final uClean = account.phone.replaceAll(RegExp(r'\D'), '');
        final idx = _users.indexWhere((u) =>
            (uClean.isNotEmpty && u.phone.replaceAll(RegExp(r'\D'), '') == uClean) ||
            u.username.toLowerCase() == account.username.toLowerCase());
        if (idx != -1) {
          _users[idx] = account;
        } else {
          _users.add(account);
        }
        notifyListeners();
        return AuthResult(
          success: true,
          message: "வெற்றிகரமாக உள்நுழைந்துள்ளீர்கள்! / Login Successful!",
          user: account,
        );
      } else if (storedPass.isNotEmpty) {
        return const AuthResult(
          success: false,
          message: "தவறான கடவுச்சொல்! / Incorrect password. Please try again.",
        );
      }
    }

    return const AuthResult(
      success: false,
      message: "தவறான பயனர் பெயர் அல்லது கடவுச்சொல்! / Invalid credentials. Please try again.",
    );
  }

  /// Register a new user account with strict uniqueness and validations
  Future<AuthResult> register({
    required String name,
    required String usernameOrPhone,
    required String phone,
    required String password,
    String email = '',
    String gender = 'Groom',
  }) async {
    final trimmedName = name.trim();
    final trimmedPhone = phone.trim().replaceAll(RegExp(r'\D'), '');
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedUser = usernameOrPhone.trim().toLowerCase();
    final trimmedPass = password.trim();

    if (trimmedName.isEmpty) {
      return const AuthResult(
        success: false,
        message: "உங்கள் பெயரை உள்ளிடவும் / Please enter your full name",
      );
    }

    if (trimmedPhone.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(trimmedPhone)) {
      return const AuthResult(
        success: false,
        message: "சரியான 10-இலக்க கைபேசி எண்ணை உள்ளிடவும் (6, 7, 8 அல்லது 9-ல் தொடங்க வேண்டும்) / Please enter valid 10-digit mobile number starting with 6, 7, 8 or 9",
      );
    }

    // 1. Mobile number must NOT be repeated for one or more accounts
    if (isPhoneRegistered(trimmedPhone)) {
      return AuthResult(
        success: false,
        message: "இந்த கைபேசி எண் ($trimmedPhone) ஏற்கனவே பதிவு செய்யப்பட்டுள்ளது! தயவுசெய்து உள்நுழையவும் / Mobile number already registered. Please login.",
      );
    }

    // 2. Validate email format & uniqueness if provided
    if (trimmedEmail.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(trimmedEmail)) {
        return const AuthResult(
          success: false,
          message: "சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும் / Please enter a valid email address",
        );
      }

      if (isEmailRegistered(trimmedEmail)) {
        return AuthResult(
          success: false,
          message: "இந்த மின்னஞ்சல் ($trimmedEmail) ஏற்கனவே பதிவு செய்யப்பட்டுள்ளது / This email is already registered",
        );
      }
    }

    if (trimmedPass.length < 6) {
      return const AuthResult(
        success: false,
        message: "கடவுச்சொல் குறைந்தபட்சம் 6 எழுத்துகள் இருக்க வேண்டும் / Password must be at least 6 characters",
      );
    }

    final newUser = UserAccount(
      name: trimmedName,
      username: trimmedUser.isNotEmpty ? trimmedUser : trimmedPhone,
      phone: trimmedPhone,
      email: trimmedEmail,
      password: trimmedPass,
      gender: gender,
    );

    _users.add(newUser);
    _currentUser = newUser;
    notifyListeners();

    // Persist login credentials & user account directly to MongoDB Database & Cache
    await MongoDBService().updateUserAccount(newUser.toMap());

    // Also persist initial user profile in MongoDB so their specific details are stored
    final gLower = gender.toLowerCase().trim();
    final bool isUserBride = gLower.contains('searching for groom') ||
        (!gLower.contains('searching for bride') && (gLower == 'bride' || gLower.contains('female')));
    final String resolvedGender = isUserBride ? "Bride" : "Groom";
    final profileDoc = {
      'id': 'PM${trimmedPhone.length >= 4 ? trimmedPhone.substring(trimmedPhone.length - 4) : DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      'name': trimmedName,
      'phone': trimmedPhone,
      'email': trimmedEmail,
      'gender': resolvedGender,
      'community': 'பண்டாரத்தார்',
      'subSect': 'பண்டாரத்தார் (Pandarathar)',
      'caste': 'Pandarathar (பண்டாரத்தார்)',
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await MongoDBService().updateUserProfile(profileDoc);

    return AuthResult(
      success: true,
      message: "கணக்கு வெற்றிகரமாக உருவாக்கப்பட்டது! / Account created successfully!",
      user: newUser,
    );
  }

  /// Update current user account details and persist to AuthService and Database
  Future<bool> updateCurrentUserAccount({
    required String name,
    required String phone,
    required String email,
    required String gender,
    Uint8List? imageBytes,
    String? profileImageUrl,
  }) async {
    final cleanPhone = phone.trim().replaceAll(RegExp(r'\D'), '');
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();

    UserAccount updatedUser;
    if (_currentUser != null) {
      final oldUser = _currentUser!;
      updatedUser = oldUser.copyWith(
        name: cleanName.isNotEmpty ? cleanName : oldUser.name,
        phone: cleanPhone.isNotEmpty ? cleanPhone : oldUser.phone,
        email: cleanEmail.isNotEmpty ? cleanEmail : oldUser.email,
        gender: gender,
        imageBytes: imageBytes ?? oldUser.imageBytes,
        profileImageUrl: profileImageUrl ?? oldUser.profileImageUrl,
      );

      final index = _users.indexWhere((u) =>
          u.username.toLowerCase() == oldUser.username.toLowerCase() ||
          u.phone.replaceAll(RegExp(r'\D'), '') == oldUser.phone.replaceAll(RegExp(r'\D'), ''));
      if (index != -1) {
        _users[index] = updatedUser;
      } else {
        _users.add(updatedUser);
      }
      _currentUser = updatedUser;
    } else {
      updatedUser = UserAccount(
        name: cleanName,
        username: cleanPhone.isNotEmpty ? cleanPhone : 'demo',
        phone: cleanPhone,
        email: cleanEmail,
        password: 'password123',
        gender: gender,
        imageBytes: imageBytes,
        profileImageUrl: profileImageUrl,
      );
      _currentUser = updatedUser;
      final index = _users.indexWhere((u) => u.phone.replaceAll(RegExp(r'\D'), '') == cleanPhone);
      if (index != -1) {
        _users[index] = updatedUser;
      } else {
        _users.add(updatedUser);
      }
    }

    notifyListeners();

    // Persist to MongoDB database
    final dbResult = await MongoDBService().updateUserAccount(updatedUser.toMap());

    // Also persist profileImageUrl to profiles collection in MongoDB so all profile screens stay in sync
    if (updatedUser.profileImageUrl != null && updatedUser.profileImageUrl!.isNotEmpty) {
      await MongoDBService().updateUserProfile({
        'phone': updatedUser.phone,
        'profileImageUrl': updatedUser.profileImageUrl,
        'r2ProfileImageUrl': updatedUser.profileImageUrl,
        'hasCustomImage': true,
      });
    }

    return dbResult;
  }

  /// Change password for current logged-in user and persist to database
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _currentUser ?? _users.first;

    if (user.password.isNotEmpty && user.password != currentPassword.trim()) {
      return const AuthResult(
        success: false,
        message: "தற்போதைய கடவுச்சொல் தவறானது / Current password is incorrect",
      );
    }

    if (newPassword.trim().length < 6) {
      return const AuthResult(
        success: false,
        message: "புதிய கடவுச்சொல் குறைந்தபட்சம் 6 எழுத்துகள் இருக்க வேண்டும் / Password must be at least 6 characters",
      );
    }

    final updated = user.copyWith(password: newPassword.trim());
    _currentUser = updated;
    final index = _users.indexWhere((u) =>
        u.username.toLowerCase() == updated.username.toLowerCase() ||
        u.phone.replaceAll(RegExp(r'\D'), '') == updated.phone.replaceAll(RegExp(r'\D'), ''));
    if (index != -1) {
      _users[index] = updated;
    }
    notifyListeners();

    // Persist to MongoDB database
    await MongoDBService().updateUserAccount(updated.toMap());

    return const AuthResult(
      success: true,
      message: "கடவுச்சொல் வெற்றிகரமாக மாற்றப்பட்டது! / Password changed successfully!",
    );
  }

  /// Logout
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}

