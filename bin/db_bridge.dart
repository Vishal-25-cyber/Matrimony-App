// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:mongo_dart/mongo_dart.dart';

const String r2AccessKeyId = "16fa39f1d2e94ee5405a9995244691f0";
const String r2SecretAccessKey = "06dfc88dcbf86cb0174233ab6670274da20d30de78383b87d2c3d08a736e1bd3";
const String r2Endpoint = "https://b535b7c908a09f10d27773b1b9536777.r2.cloudflarestorage.com";
const String r2BucketName = "matrimony-profile-images";
const String r2Host = "b535b7c908a09f10d27773b1b9536777.r2.cloudflarestorage.com";
const String r2Region = "auto";

Future<bool> uploadToR2(String objectKey, List<int> imageBytes, String contentType) async {
  final cleanKey = objectKey.startsWith('/') ? objectKey.substring(1) : objectKey;
  final now = DateTime.now().toUtc();
  final dateStamp = "${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
  final amzDate = "${dateStamp}T${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}Z";

  final payloadHash = sha256.convert(imageBytes).toString();
  final canonicalUri = "/$r2BucketName/$cleanKey";
  const canonicalQueryString = "";
  final canonicalHeaders = "host:$r2Host\nx-amz-content-sha256:$payloadHash\nx-amz-date:$amzDate\n";
  const signedHeaders = "host;x-amz-content-sha256;x-amz-date";
  final canonicalRequest = "PUT\n$canonicalUri\n$canonicalQueryString\n$canonicalHeaders\n$signedHeaders\n$payloadHash";

  const algorithm = "AWS4-HMAC-SHA256";
  final credentialScope = "$dateStamp/$r2Region/s3/aws4_request";
  final stringToSign = "$algorithm\n$amzDate\n$credentialScope\n${sha256.convert(utf8.encode(canonicalRequest))}";

  List<int> sign(List<int> key, String msg) => Hmac(sha256, key).convert(utf8.encode(msg)).bytes;
  final kDate = sign(utf8.encode("AWS4$r2SecretAccessKey"), dateStamp);
  final kRegion = sign(kDate, r2Region);
  final kService = sign(kRegion, "s3");
  final signingKey = sign(kService, "aws4_request");
  final signature = Hmac(sha256, signingKey).convert(utf8.encode(stringToSign)).toString();

  final authorizationHeader = "$algorithm Credential=$r2AccessKeyId/$credentialScope, SignedHeaders=$signedHeaders, Signature=$signature";

  final uri = Uri.parse("$r2Endpoint/$r2BucketName/$cleanKey");
  try {
    final response = await http.put(
      uri,
      headers: {
        'Host': r2Host,
        'Content-Type': contentType,
        'x-amz-date': amzDate,
        'x-amz-content-sha256': payloadHash,
        'Authorization': authorizationHeader,
      },
      body: imageBytes,
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      print("✓ [Bridge] Successfully uploaded to Cloudflare R2: $cleanKey (${imageBytes.length} bytes)");
      return true;
    } else {
      print("⚠ [Bridge] R2 upload failed status: ${response.statusCode}, body: ${response.body}");
      return false;
    }
  } catch (e) {
    print("⚠ [Bridge] R2 upload error: $e");
    return false;
  }
}

String generateR2PresignedUrl(String objectKey, {int expiresInSeconds = 604800}) {
  final cleanKey = objectKey.startsWith('/') ? objectKey.substring(1) : objectKey;
  final now = DateTime.now().toUtc();
  final dateStamp = "${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
  final amzDate = "${dateStamp}T${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}Z";

  const algorithm = "AWS4-HMAC-SHA256";
  final credentialScope = "$dateStamp/$r2Region/s3/aws4_request";
  final credential = Uri.encodeComponent("$r2AccessKeyId/$credentialScope");
  const signedHeaders = "host";

  final queryParams = [
    "X-Amz-Algorithm=$algorithm",
    "X-Amz-Credential=$credential",
    "X-Amz-Date=$amzDate",
    "X-Amz-Expires=$expiresInSeconds",
    "X-Amz-SignedHeaders=$signedHeaders",
  ];
  queryParams.sort();
  final canonicalQueryString = queryParams.join('&');

  final canonicalUri = "/$r2BucketName/$cleanKey";
  final canonicalHeaders = "host:$r2Host\n";
  const payloadHash = "UNSIGNED-PAYLOAD";

  final canonicalRequest = "GET\n$canonicalUri\n$canonicalQueryString\n$canonicalHeaders\n$signedHeaders\n$payloadHash";
  final stringToSign = "$algorithm\n$amzDate\n$credentialScope\n${sha256.convert(utf8.encode(canonicalRequest))}";

  List<int> sign(List<int> key, String msg) => Hmac(sha256, key).convert(utf8.encode(msg)).bytes;
  final kDate = sign(utf8.encode("AWS4$r2SecretAccessKey"), dateStamp);
  final kRegion = sign(kDate, r2Region);
  final kService = sign(kRegion, "s3");
  final signingKey = sign(kService, "aws4_request");
  final signature = Hmac(sha256, signingKey).convert(utf8.encode(stringToSign)).toString();

  return "$r2Endpoint/$r2BucketName/$cleanKey?$canonicalQueryString&X-Amz-Signature=$signature";
}

void main() async {
  const uri = "mongodb+srv://vishal250820_db_user:vishal25082006@portfolio.mo5wnyq.mongodb.net/pandarathar_matrimony?appName=portfolio";
  final port = 8765;

  print("Starting MongoDB Atlas HTTP Web Bridge on port $port...");
  Db? db;

  Future<Db?> getDb({bool forceReconnect = false}) async {
    if (!forceReconnect && db != null && db!.state == State.open && db!.isConnected) {
      return db;
    }
    try {
      if (db != null) {
        try {
          await db!.close();
        } catch (_) {}
      }
      db = await Db.create(uri);
      await db!.open();
      print("✓ Bridge connected to MongoDB Atlas!");
      return db;
    } catch (e) {
      print("Bridge connection error: $e");
      return null;
    }
  }

  // Pre-connect
  await getDb();

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  print("✓ MongoDB Atlas Bridge listening at http://127.0.0.1:$port");

  await for (HttpRequest request in server) {
    // Add CORS headers for Flutter Web
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type, Origin, Accept, Authorization');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      continue;
    }

    final path = request.uri.path;
    try {
      var activeDb = await getDb();
      if (activeDb == null) {
        request.response.statusCode = HttpStatus.serviceUnavailable;
        request.response.write(jsonEncode({'error': 'MongoDB Atlas unavailable'}));
        await request.response.close();
        continue;
      }

      if (path == '/api/health') {
        request.response.statusCode = HttpStatus.ok;
        request.response.write(jsonEncode({'status': 'ok', 'cluster': 'portfolio.mo5wnyq.mongodb.net'}));
        await request.response.close();
        continue;
      }

      if (path == '/api/user' && request.method == 'POST') {
        final bodyStr = await utf8.decoder.bind(request).join();
        final data = jsonDecode(bodyStr) as Map<String, dynamic>;
        final phone = data['phone']?.toString() ?? '';
        final username = data['username']?.toString() ?? '';
        final email = data['email']?.toString() ?? '';

        final usersCol = activeDb.collection('users');
        Map<String, dynamic>? existing;
        if (phone.isNotEmpty) {
          existing = await usersCol.findOne(where.eq('phone', phone));
        }
        if (existing == null && username.isNotEmpty) {
          existing = await usersCol.findOne(where.eq('username', username.toLowerCase()));
        }
        if (existing == null && email.isNotEmpty) {
          existing = await usersCol.findOne(where.eq('email', email.toLowerCase()));
        }

        if (existing != null) {
          await usersCol.update(where.id(existing['_id']), {r'$set': data});
          print("✓ [Bridge] User updated in Atlas: ${data['name']} ($phone / $username)");
        } else {
          await usersCol.insert(data);
          print("✓ [Bridge] New user inserted in Atlas: ${data['name']} ($phone / $username)");
        }

        request.response.statusCode = HttpStatus.ok;
        request.response.write(jsonEncode({'success': true}));
        await request.response.close();
        continue;
      }

      if (path == '/api/user' && request.method == 'GET') {
        final query = request.uri.queryParameters['query'] ?? '';
        final queryLower = query.toLowerCase();
        final clean = query.replaceAll(RegExp(r'\D'), '');

        final usersCol = activeDb.collection('users');
        Map<String, dynamic>? doc;
        try {
          if (clean.isNotEmpty) {
            doc = await usersCol.findOne(where.eq('phone', clean));
            doc ??= await usersCol.findOne(where.eq('phone', query));
          }
          doc ??= await usersCol.findOne(where.eq('username', queryLower));
          doc ??= await usersCol.findOne(where.eq('email', queryLower));
          doc ??= await usersCol.findOne(where.match('name', '^$query\$', caseInsensitive: true));
        } catch (e) {
          if (e.toString().contains('No master connection')) {
            activeDb = await getDb(forceReconnect: true);
            if (activeDb != null) {
              final retryCol = activeDb.collection('users');
              if (clean.isNotEmpty) {
                doc = await retryCol.findOne(where.eq('phone', clean));
                doc ??= await retryCol.findOne(where.eq('phone', query));
              }
              doc ??= await retryCol.findOne(where.eq('username', queryLower));
              doc ??= await retryCol.findOne(where.eq('email', queryLower));
            }
          } else {
            rethrow;
          }
        }

        request.response.statusCode = HttpStatus.ok;
        request.response.write(jsonEncode({'success': true, 'user': doc}));
        await request.response.close();
        continue;
      }

      if (path == '/api/profile' && request.method == 'POST') {
        final bodyStr = await utf8.decoder.bind(request).join();
        final data = jsonDecode(bodyStr) as Map<String, dynamic>;
        final id = data['id']?.toString() ?? '';
        final phone = data['phone']?.toString() ?? '';
        final email = data['email']?.toString() ?? '';
        final name = data['name']?.toString() ?? '';

        final profilesCol = activeDb.collection('profiles');
        Map<String, dynamic>? existing;
        if (id.isNotEmpty) {
          existing = await profilesCol.findOne(where.eq('id', id));
        }
        if (existing == null && phone.isNotEmpty) {
          existing = await profilesCol.findOne(where.eq('phone', phone));
        }
        if (existing == null && email.isNotEmpty) {
          existing = await profilesCol.findOne(where.eq('email', email.toLowerCase()));
        }
        if (existing == null && name.isNotEmpty) {
          existing = await profilesCol.findOne(where.match('name', '(?i)^$name\$'));
        }

        if (existing != null) {
          await profilesCol.update(where.id(existing['_id']), {r'$set': data});
          print("✓ [Bridge] Profile updated in Atlas: ${data['name']} ($id / $phone)");
        } else {
          await profilesCol.insert(data);
          print("✓ [Bridge] New profile inserted in Atlas: ${data['name']} ($id / $phone)");
        }

        // Also sync users login collection with updated phone & name
        if (phone.isNotEmpty || email.isNotEmpty) {
          try {
            final usersCol = activeDb.collection('users');
            Map<String, dynamic>? userDoc;
            if (email.isNotEmpty) {
              userDoc = await usersCol.findOne(where.eq('email', email.toLowerCase()));
            }
            if (userDoc == null && phone.isNotEmpty) {
              userDoc = await usersCol.findOne(where.eq('phone', phone));
            }
            if (userDoc != null) {
              await usersCol.update(where.id(userDoc['_id']), {
                r'$set': {
                  if (name.isNotEmpty) 'name': name,
                  if (phone.isNotEmpty) 'phone': phone,
                  if (phone.isNotEmpty) 'username': phone,
                  if (email.isNotEmpty) 'email': email,
                  'updatedAt': DateTime.now().toIso8601String(),
                }
              });
              print("✓ [Bridge] Synced login account in Atlas: $phone ($name)");
            }
          } catch (_) {}
        }

        request.response.statusCode = HttpStatus.ok;
        request.response.write(jsonEncode({'success': true}));
        await request.response.close();
        continue;
      }

      if (path == '/api/profile' && request.method == 'GET') {
        final query = request.uri.queryParameters['query'] ?? '';
        final clean = query.replaceAll(RegExp(r'\D'), '');

        final profilesCol = activeDb.collection('profiles');
        Map<String, dynamic>? doc;
        try {
          if (clean.isNotEmpty) {
            doc = await profilesCol.findOne(where.eq('phone', clean));
            doc ??= await profilesCol.findOne(where.eq('phone', query));
          }
          doc ??= await profilesCol.findOne(where.eq('id', query));
          doc ??= await profilesCol.findOne(where.match('name', '^$query\$', caseInsensitive: true));
        } catch (e) {
          if (e.toString().contains('No master connection')) {
            activeDb = await getDb(forceReconnect: true);
            if (activeDb != null) {
              final retryCol = activeDb.collection('profiles');
              if (clean.isNotEmpty) {
                doc = await retryCol.findOne(where.eq('phone', clean));
                doc ??= await retryCol.findOne(where.eq('phone', query));
              }
              doc ??= await retryCol.findOne(where.eq('id', query));
              doc ??= await retryCol.findOne(where.match('name', '^$query\$', caseInsensitive: true));
            }
          } else {
            rethrow;
          }
        }

        request.response.statusCode = HttpStatus.ok;
        request.response.write(jsonEncode({'success': true, 'profile': doc}));
        await request.response.close();
        continue;
      }

      if (path == '/api/shortlist' && request.method == 'GET') {
        final userId = request.uri.queryParameters['userId'] ?? '';
        final userPhone = request.uri.queryParameters['userPhone'] ?? '';
        final cleanPhone = userPhone.replaceAll(RegExp(r'\D'), '');

        final shortlistsCol = activeDb.collection('shortlists');
        Map<String, dynamic>? doc;
        if (userId.isNotEmpty) {
          doc = await shortlistsCol.findOne(where.eq('userId', userId));
        }
        if (doc == null && cleanPhone.isNotEmpty) {
          doc = await shortlistsCol.findOne(where.eq('userPhone', cleanPhone));
          doc ??= await shortlistsCol.findOne(where.eq('userPhone', userPhone));
        }
        if (doc == null && cleanPhone.isNotEmpty) {
          doc = await shortlistsCol.findOne(where.match('userPhone', '.*$cleanPhone.*'));
        }

        request.response.statusCode = HttpStatus.ok;
        request.response.write(jsonEncode({'success': true, 'shortlist': doc}));
        await request.response.close();
        continue;
      }

      if (path == '/api/shortlist' && request.method == 'POST') {
        final bodyStr = await utf8.decoder.bind(request).join();
        final data = jsonDecode(bodyStr) as Map<String, dynamic>;
        final userId = data['userId']?.toString() ?? '';
        final userPhone = data['userPhone']?.toString() ?? '';
        final cleanPhone = userPhone.replaceAll(RegExp(r'\D'), '');

        final shortlistsCol = activeDb.collection('shortlists');
        final selector = userId.isNotEmpty
            ? where.eq('userId', userId)
            : (cleanPhone.isNotEmpty ? where.eq('userPhone', cleanPhone) : where.eq('userPhone', userPhone));
        await shortlistsCol.update(selector, {r'$set': data}, upsert: true);
        print("✓ [Bridge] Shortlist updated in Atlas for user: $userId (Phone: $userPhone, count: ${(data['profileIds'] as List?)?.length})");

        request.response.statusCode = HttpStatus.ok;
        request.response.write(jsonEncode({'success': true}));
        await request.response.close();
        continue;
      }

      if (path == '/api/payments' && request.method == 'GET') {
        final userId = request.uri.queryParameters['userId'] ?? '';
        final userPhone = request.uri.queryParameters['userPhone'] ?? '';
        final cleanPhone = userPhone.replaceAll(RegExp(r'\D'), '');

        final paymentsCol = activeDb.collection('payments');
        List<Map<String, dynamic>> docs;
        if (userId.isNotEmpty && cleanPhone.isNotEmpty) {
          docs = await paymentsCol.find(
            where.eq('userId', userId).or(where.eq('userPhone', cleanPhone)).or(where.eq('userPhone', userPhone)),
          ).toList();
        } else if (userId.isNotEmpty) {
          docs = await paymentsCol.find(where.eq('userId', userId)).toList();
        } else if (cleanPhone.isNotEmpty) {
          docs = await paymentsCol.find(where.eq('userPhone', cleanPhone).or(where.eq('userPhone', userPhone))).toList();
        } else {
          docs = await paymentsCol.find().toList();
        }

        request.response.statusCode = HttpStatus.ok;
        request.response.write(jsonEncode({'success': true, 'payments': docs}));
        await request.response.close();
        continue;
      }

      if (path == '/api/payment' && request.method == 'POST') {
        final bodyStr = await utf8.decoder.bind(request).join();
        final data = jsonDecode(bodyStr) as Map<String, dynamic>;
        final id = data['id']?.toString() ?? '';
        final status = data['status']?.toString() ?? 'pending';

        final paymentsCol = activeDb.collection('payments');
        await paymentsCol.update(where.eq('id', id), {r'$set': data}, upsert: true);
        print("✓ [Bridge] Payment stored/updated in Atlas: $id (Status: $status)");

        // If approved, automatically unlock contacts & horoscope in Atlas profiles collection
        if (status == 'approved' && data['profileIds'] is List) {
          final profilesCol = activeDb.collection('profiles');
          for (final pid in (data['profileIds'] as List)) {
            await profilesCol.update(
              where.eq('id', pid.toString()),
              {r'$set': {'isContactUnlocked': true, 'isHoroscopeUnlocked': true}},
              upsert: false,
            );
          }
          print("✓ [Bridge] Automatically marked profiles as unlocked in Atlas: ${data['profileIds']}");
        }

        request.response.statusCode = HttpStatus.ok;
        request.response.write(jsonEncode({'success': true}));
        await request.response.close();
        continue;
      }

      if (path == '/api/profiles' && request.method == 'GET') {
        final profilesCol = activeDb.collection('profiles');
        final docs = await profilesCol.find().toList();
        request.response.statusCode = HttpStatus.ok;
        request.response.write(jsonEncode({'success': true, 'profiles': docs}));
        await request.response.close();
        continue;
      }

      // DELETE Profile from MongoDB Atlas
      if ((path == '/api/profile' && request.method == 'DELETE') ||
          (path == '/api/profile/delete' && (request.method == 'POST' || request.method == 'DELETE'))) {
        String id = request.uri.queryParameters['id'] ?? '';
        String phone = request.uri.queryParameters['phone'] ?? '';

        if (id.isEmpty && phone.isEmpty) {
          try {
            final bodyStr = await utf8.decoder.bind(request).join();
            if (bodyStr.isNotEmpty) {
              final data = jsonDecode(bodyStr) as Map<String, dynamic>;
              id = data['id']?.toString() ?? '';
              phone = data['phone']?.toString() ?? '';
            }
          } catch (_) {}
        }

        final profilesCol = activeDb.collection('profiles');
        final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

        var selector = where;
        if (id.isNotEmpty && cleanPhone.isNotEmpty) {
          selector = where.eq('id', id).or(where.eq('phone', cleanPhone)).or(where.eq('phone', phone));
        } else if (id.isNotEmpty) {
          selector = where.eq('id', id);
        } else if (cleanPhone.isNotEmpty) {
          selector = where.eq('phone', cleanPhone).or(where.eq('phone', phone));
        } else {
          request.response.statusCode = HttpStatus.badRequest;
          request.response.write(jsonEncode({'error': 'Profile id or phone required for deletion'}));
          await request.response.close();
          continue;
        }

        final result = await profilesCol.remove(selector);
        print("✓ [Bridge] Profile deleted from Atlas: id=$id, phone=$phone, result=$result");

        // Also clean up from shortlists collection
        if (id.isNotEmpty) {
          try {
            final shortlistsCol = activeDb.collection('shortlists');
            await shortlistsCol.update(
              where.exists('profileIds'),
              {
                r'$pull': {'profileIds': id}
              },
              multiUpdate: true,
            );
          } catch (_) {}
        }

        request.response.statusCode = HttpStatus.ok;
        request.response.write(jsonEncode({'success': true, 'deleted': id.isNotEmpty ? id : phone}));
        await request.response.close();
        continue;
      }

      // Cloudflare R2 Image Upload Endpoint
      if (path == '/api/r2-upload' && request.method == 'POST') {
        try {
          final bodyStr = await utf8.decoder.bind(request).join();
          final data = jsonDecode(bodyStr) as Map<String, dynamic>;
          final objectKey = data['objectKey']?.toString() ?? '';
          final base64Image = data['imageBase64']?.toString() ?? '';
          final contentType = data['contentType']?.toString() ?? 'image/jpeg';

          if (objectKey.isEmpty || base64Image.isEmpty) {
            request.response.statusCode = HttpStatus.badRequest;
            request.response.write(jsonEncode({'error': 'objectKey and imageBase64 are required'}));
            await request.response.close();
            continue;
          }

          final imageBytes = base64Decode(base64Image);
          final uploadSuccess = await uploadToR2(objectKey, imageBytes, contentType);

          if (uploadSuccess) {
            final presignedUrl = generateR2PresignedUrl(objectKey);
            request.response.statusCode = HttpStatus.ok;
            request.response.write(jsonEncode({
              'success': true,
              'objectKey': objectKey,
              'url': presignedUrl,
            }));
          } else {
            request.response.statusCode = HttpStatus.internalServerError;
            request.response.write(jsonEncode({'error': 'Failed to upload to Cloudflare R2'}));
          }
        } catch (e) {
          request.response.statusCode = HttpStatus.internalServerError;
          request.response.write(jsonEncode({'error': e.toString()}));
        }
        await request.response.close();
        continue;
      }

      // Cloudflare R2 Image Fetch / Proxy Endpoint with CORS for Web
      if (path == '/api/r2-image' && request.method == 'GET') {
        try {
          final objectKey = request.uri.queryParameters['key'] ?? '';
          if (objectKey.isEmpty) {
            request.response.statusCode = HttpStatus.badRequest;
            request.response.write(jsonEncode({'error': 'key query parameter is required'}));
            await request.response.close();
            continue;
          }

          final cleanKey = objectKey.startsWith('/') ? objectKey.substring(1) : objectKey;
          final presignedUrl = generateR2PresignedUrl(cleanKey, expiresInSeconds: 3600);
          final r2Res = await http.get(Uri.parse(presignedUrl)).timeout(const Duration(seconds: 10));

          if (r2Res.statusCode == 200) {
            final mime = cleanKey.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
            request.response.headers.contentType = ContentType.parse(mime);
            request.response.headers.add('Cache-Control', 'public, max-age=86400');
            request.response.statusCode = HttpStatus.ok;
            request.response.add(r2Res.bodyBytes);
          } else {
            request.response.statusCode = r2Res.statusCode;
            request.response.write(jsonEncode({'error': 'Image not found in R2'}));
          }
        } catch (e) {
          request.response.statusCode = HttpStatus.internalServerError;
          request.response.write(jsonEncode({'error': e.toString()}));
        }
        await request.response.close();
        continue;
      }

      request.response.statusCode = HttpStatus.notFound;
      request.response.write(jsonEncode({'error': 'Not found'}));
      await request.response.close();
    } catch (e) {
      if (e.toString().contains('No master connection') || e.toString().contains('closed')) {
        await getDb(forceReconnect: true);
      }
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.write(jsonEncode({'error': e.toString()}));
      await request.response.close();
    }
  }
}
