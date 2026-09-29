// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:mongo_dart/mongo_dart.dart';

// ==============================================================================
// 1. DYNAMIC ENVIRONMENT CONFIGURATION (.env & Platform.environment)
// ==============================================================================
Map<String, String> loadEnvFile([String path = '.env']) {
  final env = <String, String>{};
  final file = File(path);
  if (file.existsSync()) {
    try {
      final lines = file.readAsLinesSync();
      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty || line.startsWith('#')) continue;
        final eqIdx = line.indexOf('=');
        if (eqIdx != -1) {
          final key = line.substring(0, eqIdx).trim();
          var val = line.substring(eqIdx + 1).trim();
          if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
            val = val.substring(1, val.length - 1);
          }
          env[key] = val;
        }
      }
    } catch (e) {
      print("ℹ [Bridge] Notice reading $path: $e");
    }
  }
  return env;
}

final Map<String, String> _env = loadEnvFile('.env');
String getEnv(String key, [String defaultValue = '']) {
  return Platform.environment[key] ?? _env[key] ?? defaultValue;
}

// Cloudflare R2 Credentials & Parameters loaded strictly on server-side
final String r2AccountId = getEnv('CLOUDFLARE_R2_ACCOUNT_ID', 'b535b7c908a09f10d27773b1b9536777');
final String r2AccessKeyId = getEnv('CLOUDFLARE_R2_ACCESS_KEY_ID', '16fa39f1d2e94ee5405a9995244691f0');
final String r2SecretAccessKey = getEnv('CLOUDFLARE_R2_SECRET_ACCESS_KEY', '06dfc88dcbf86cb0174233ab6670274da20d30de78383b87d2c3d08a736e1bd3');
final String r2BucketName = getEnv('CLOUDFLARE_R2_BUCKET_NAME', 'matrimony-profile-images');
final String r2Prefix = getEnv('CLOUDFLARE_R2_PREFIX', 'profiles/');
final String r2Endpoint = getEnv('CLOUDFLARE_R2_ENDPOINT', 'https://$r2AccountId.r2.cloudflarestorage.com');
final String r2PublicUrlPrefix = getEnv('CLOUDFLARE_R2_PUBLIC_URL_PREFIX', '');
final String r2Host = Uri.parse(r2Endpoint).host;
const String r2Region = "auto";
final String mongoAtlasUri = () {
  var uri = getEnv(
    'MONGODB_ATLAS_URI',
    'mongodb+srv://vishal250820_db_user:vishal25082006@portfolio.mo5wnyq.mongodb.net/pandarathar_matrimony?appName=portfolio&safeAtlas=true',
  );
  if (!uri.contains('safeAtlas=true')) {
    uri += (uri.contains('?') ? '&' : '?') + 'safeAtlas=true';
  }
  return uri;
}();

// In-memory image cache for instant, zero-latency avatar rendering in Flutter Web
final Map<String, List<int>> _imageCache = {};

// In-memory document caches for sub-millisecond query responses
final Map<String, Map<String, dynamic>> _userDocCache = {};
final Map<String, Map<String, dynamic>> _profileDocCache = {};
final Map<String, Map<String, dynamic>> _shortlistDocCache = {};
final Map<String, List<Map<String, dynamic>>> _paymentsDocCache = {};

// ==============================================================================
// 2. IMAGE VALIDATION (MAGIC BYTES & SIZE LIMIT)
// ==============================================================================
class ImageValidationResult {
  final bool isValid;
  final String contentType;
  final String extension;
  final String? error;

  ImageValidationResult.valid({required this.contentType, required this.extension})
      : isValid = true,
        error = null;

  ImageValidationResult.invalid(this.error)
      : isValid = false,
        contentType = '',
        extension = '';
}

ImageValidationResult validateImageBytes(List<int> bytes) {
  const maxBytes = 5 * 1024 * 1024; // 5 MB max
  if (bytes.isEmpty) {
    return ImageValidationResult.invalid("No image data received / empty file");
  }
  if (bytes.length > maxBytes) {
    final sizeMb = (bytes.length / (1024 * 1024)).toStringAsFixed(2);
    return ImageValidationResult.invalid("Image file size exceeds 5MB limit ($sizeMb MB)");
  }
  if (bytes.length < 12) {
    return ImageValidationResult.invalid("File is too small to be a valid image");
  }

  // 1. JPEG: FF D8 FF
  if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
    return ImageValidationResult.valid(contentType: 'image/jpeg', extension: 'jpg');
  }

  // 2. PNG: 89 50 4E 47 0D 0A 1A 0A
  if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
    return ImageValidationResult.valid(contentType: 'image/png', extension: 'png');
  }

  // 3. WebP: 52 49 46 46 (RIFF) ... 57 45 42 50 (WEBP)
  if (bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 &&
      bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50) {
    return ImageValidationResult.valid(contentType: 'image/webp', extension: 'webp');
  }

  return ImageValidationResult.invalid("Unsupported image format. Allowed formats: JPG, JPEG, PNG, and WebP.");
}

// ==============================================================================
// 3. MULTIPART / FORM-DATA PARSER
// ==============================================================================
class MultipartParsedResult {
  final Map<String, String> fields;
  final List<MultipartFileEntry> files;
  MultipartParsedResult({required this.fields, required this.files});
}

class MultipartFileEntry {
  final String fieldName;
  final String fileName;
  final String contentType;
  final List<int> bytes;
  MultipartFileEntry({required this.fieldName, required this.fileName, required this.contentType, required this.bytes});
}

MultipartParsedResult parseMultipartData(List<int> bodyBytes, String boundary) {
  final fields = <String, String>{};
  final files = <MultipartFileEntry>[];
  final boundaryBytes = utf8.encode("--$boundary");
  final doubleNewline = [13, 10, 13, 10]; // \r\n\r\n
  final singleNewline = [10, 10]; // \n\n

  int search(List<int> src, List<int> pattern, int start) {
    for (int i = start; i <= src.length - pattern.length; i++) {
      bool match = true;
      for (int j = 0; j < pattern.length; j++) {
        if (src[i + j] != pattern[j]) { match = false; break; }
      }
      if (match) return i;
    }
    return -1;
  }

  int pos = search(bodyBytes, boundaryBytes, 0);
  while (pos != -1) {
    pos += boundaryBytes.length;
    if (pos >= bodyBytes.length - 2) break;
    // Check if end of multipart (starts with --)
    if (bodyBytes[pos] == 45 && bodyBytes[pos + 1] == 45) break;
    // Skip \r\n
    if (bodyBytes[pos] == 13 && bodyBytes[pos + 1] == 10) {
      pos += 2;
    } else if (bodyBytes[pos] == 10) {
      pos += 1;
    }

    final nextBoundary = search(bodyBytes, boundaryBytes, pos);
    if (nextBoundary == -1) break;

    int headerEnd = search(bodyBytes, doubleNewline, pos);
    int bodyStart = 0;
    if (headerEnd != -1 && headerEnd < nextBoundary) {
      bodyStart = headerEnd + 4;
    } else {
      headerEnd = search(bodyBytes, singleNewline, pos);
      if (headerEnd != -1 && headerEnd < nextBoundary) {
        bodyStart = headerEnd + 2;
      }
    }

    if (bodyStart > 0 && bodyStart <= nextBoundary) {
      final headerStr = utf8.decode(bodyBytes.sublist(pos, headerEnd), allowMalformed: true);
      var partEnd = nextBoundary;
      if (partEnd >= 2 && bodyBytes[partEnd - 2] == 13 && bodyBytes[partEnd - 1] == 10) {
        partEnd -= 2;
      } else if (partEnd >= 1 && bodyBytes[partEnd - 1] == 10) {
        partEnd -= 1;
      }
      final partBytes = bodyBytes.sublist(bodyStart, partEnd);

      final dispositionMatch = RegExp(r'name="([^"]+)"').firstMatch(headerStr);
      final filenameMatch = RegExp(r'filename="([^"]+)"').firstMatch(headerStr);
      final contentTypeMatch = RegExp(r'Content-Type:\s*([^\r\n;]+)', caseSensitive: false).firstMatch(headerStr);

      final name = dispositionMatch?.group(1) ?? '';
      final filename = filenameMatch?.group(1);
      final cType = contentTypeMatch?.group(1)?.trim() ?? 'application/octet-stream';

      if (filename != null && filename.isNotEmpty) {
        files.add(MultipartFileEntry(fieldName: name, fileName: filename, contentType: cType, bytes: partBytes));
      } else if (name.isNotEmpty) {
        fields[name] = utf8.decode(partBytes, allowMalformed: true).trim();
      }
    }
    pos = nextBoundary;
  }
  return MultipartParsedResult(fields: fields, files: files);
}

// ==============================================================================
// 4. CLOUDFLARE R2 S3-COMPATIBLE API (AWS SIGV4)
// ==============================================================================
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
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200 || response.statusCode == 204) {
      _imageCache[cleanKey] = imageBytes;
      print("✓ [Bridge] Uploaded to Cloudflare R2: $cleanKey (${imageBytes.length} bytes)");
      return true;
    } else {
      print("⚠ [Bridge] R2 upload failed HTTP ${response.statusCode}");
      return false;
    }
  } catch (e) {
    print("⚠ [Bridge] R2 upload error: $e");
    return false;
  }
}

Future<bool> deleteFromR2(String objectKey) async {
  final cleanKey = objectKey.startsWith('/') ? objectKey.substring(1) : objectKey;
  final now = DateTime.now().toUtc();
  final dateStamp = "${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
  final amzDate = "${dateStamp}T${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}Z";

  final payloadHash = sha256.convert([]).toString();
  final canonicalUri = "/$r2BucketName/$cleanKey";
  const canonicalQueryString = "";
  final canonicalHeaders = "host:$r2Host\nx-amz-content-sha256:$payloadHash\nx-amz-date:$amzDate\n";
  const signedHeaders = "host;x-amz-content-sha256;x-amz-date";
  final canonicalRequest = "DELETE\n$canonicalUri\n$canonicalQueryString\n$canonicalHeaders\n$signedHeaders\n$payloadHash";

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
    final response = await http.delete(
      uri,
      headers: {
        'Host': r2Host,
        'x-amz-date': amzDate,
        'x-amz-content-sha256': payloadHash,
        'Authorization': authorizationHeader,
      },
    ).timeout(const Duration(seconds: 15));

    _imageCache.remove(cleanKey);
    print("✓ [Bridge] Deleted from Cloudflare R2: $cleanKey (HTTP ${response.statusCode})");
    return response.statusCode == 200 || response.statusCode == 204;
  } catch (e) {
    print("⚠ [Bridge] R2 delete error for $cleanKey: $e");
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

// ==============================================================================
// 5. SERVER ENTRYPOINT & HTTP ROUTING
// ==============================================================================
void main() async {
  const port = 8765;

  print("Starting Secure Cloudflare R2 & MongoDB Atlas HTTP API on port $port...");
  Db? db;
  bool isConnecting = false;

  Future<Db?> getDb({bool forceReconnect = false}) async {
    final isAlive = db != null && db!.state == State.open && db!.isConnected && db!.masterConnection != null;
    if (!forceReconnect && isAlive) {
      return db;
    }
    if (isConnecting) {
      for (int i = 0; i < 25; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        final activeNow = db != null && db!.state == State.open && db!.isConnected && db!.masterConnection != null;
        if (activeNow) return db;
        if (!isConnecting) break;
      }
    }
    isConnecting = true;
    try {
      if (db != null) {
        try {
          await db!.close().timeout(const Duration(seconds: 2));
        } catch (_) {}
      }
      db = await Db.create(mongoAtlasUri);
      await db!.open().timeout(const Duration(seconds: 8));
      print("✓ Connected to MongoDB Atlas!");
      return db;
    } catch (e) {
      print("⚠ MongoDB connection notice: $e");
      return null;
    } finally {
      isConnecting = false;
    }
  }

  // Pre-connect in background without blocking server bind
  getDb().ignore();

  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print("✓ Backend API listening at http://127.0.0.1:$port");

  server.listen((HttpRequest request) async {
    // Add CORS headers for Flutter Web
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS, HEAD');
    request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type, Origin, Accept, Authorization, X-User-Id');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      return;
    }

    final path = request.uri.path;

    // Fast-path health check
    if (path == '/api/health') {
      final isDbUp = db != null && db!.state == State.open;
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({
        'status': 'ok',
        'r2Configured': r2AccessKeyId.isNotEmpty && r2SecretAccessKey.isNotEmpty,
        'r2Bucket': r2BucketName,
        'dbConnected': isDbUp,
      }));
      await request.response.close();
      return;
    }

    // -------------------------------------------------------------
    // PROFILE IMAGE UPLOAD (POST /api/profile/upload-image & /api/r2-upload)
    // -------------------------------------------------------------
    if ((path == '/api/profile/upload-image' || path == '/api/r2-upload') && request.method == 'POST') {
      try {
        final cTypeHeader = request.headers.contentType?.mimeType.toLowerCase() ?? '';
        final authHeader = request.headers.value('authorization') ?? '';
        final xUserIdHeader = request.headers.value('x-user-id') ?? '';
        final queryUserId = request.uri.queryParameters['userId'] ?? '';

        String userId = '';
        if (xUserIdHeader.isNotEmpty) {
          userId = xUserIdHeader;
        } else if (authHeader.isNotEmpty) {
          userId = authHeader.replaceFirst(RegExp(r'^[Bb]earer\s+'), '').trim();
        } else if (queryUserId.isNotEmpty) {
          userId = queryUserId;
        }

        List<int> imageBytes = [];
        String oldKey = '';

        if (cTypeHeader.contains('multipart/form-data')) {
          final boundary = request.headers.contentType?.parameters['boundary'] ?? '';
          final rawBody = await request.fold<List<int>>([], (prev, element) => prev..addAll(element));
          final parsed = parseMultipartData(rawBody, boundary);
          if (parsed.fields.containsKey('userId') && userId.isEmpty) {
            userId = parsed.fields['userId']!;
          }
          if (parsed.fields.containsKey('oldKey')) {
            oldKey = parsed.fields['oldKey']!;
          }
          if (parsed.files.isNotEmpty) {
            imageBytes = parsed.files.first.bytes;
          }
        } else if (cTypeHeader.contains('application/json')) {
          final bodyStr = await utf8.decoder.bind(request).join();
          final data = jsonDecode(bodyStr) as Map<String, dynamic>;
          if (userId.isEmpty && data['userId'] != null) {
            userId = data['userId'].toString();
          }
          oldKey = data['oldKey']?.toString() ?? data['oldImageUrl']?.toString() ?? '';
          final base64Str = data['imageBase64']?.toString() ?? data['image']?.toString() ?? '';
          if (base64Str.isNotEmpty) {
            imageBytes = base64Decode(base64Str);
          }
        } else {
          imageBytes = await request.fold<List<int>>([], (prev, element) => prev..addAll(element));
        }

        if (userId.trim().isEmpty) {
          request.response.statusCode = HttpStatus.unauthorized;
          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode({'error': 'Authentication required. Missing userId or Authorization header.'}));
          await request.response.close();
          return;
        }

        final validation = validateImageBytes(imageBytes);
        if (!validation.isValid) {
          request.response.statusCode = imageBytes.length > 5 * 1024 * 1024
              ? HttpStatus.requestEntityTooLarge
              : HttpStatus.badRequest;
          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode({'error': validation.error}));
          await request.response.close();
          return;
        }

        // Generate deterministic, safe unique object key: profiles/<user_id>_avatar.<ext>
        final cleanUserId = userId.trim().toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
        final objectKey = "$r2Prefix${cleanUserId}_avatar.${validation.extension}";

        // Cleanup previous photo if different extension
        var activeDb = await getDb();
        if (activeDb != null && oldKey.isEmpty) {
          try {
            final existingUser = await activeDb.collection('users').findOne(
              where.eq('phone', userId).or(where.eq('username', userId)).or(where.eq('phone', cleanUserId)),
            );
            oldKey = existingUser?['profileImageKey']?.toString() ?? '';
          } catch (_) {}
        }
        if (oldKey.isNotEmpty && oldKey != objectKey) {
          final cleanOldKey = oldKey.contains(r2BucketName)
              ? oldKey.substring(oldKey.indexOf(r2BucketName) + r2BucketName.length + 1)
              : oldKey;
          deleteFromR2(cleanOldKey).ignore();
        }

        final uploadSuccess = await uploadToR2(objectKey, imageBytes, validation.contentType);
        if (!uploadSuccess) {
          request.response.statusCode = HttpStatus.badGateway;
          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode({'error': 'Failed to upload image to Cloudflare R2'}));
          await request.response.close();
          return;
        }

        final presignedUrl = generateR2PresignedUrl(objectKey);
        final cleanKey = objectKey.startsWith('/') ? objectKey.substring(1) : objectKey;
        _imageCache[cleanKey] = imageBytes;

        // Store metadata ONLY in MongoDB Atlas - NO raw binary data
        if (activeDb != null) {
          try {
            final cleanPhone = userId.replaceAll(RegExp(r'\D'), '');
            final updateDoc = {
              'profileImageKey': objectKey,
              'profileImageUrl': presignedUrl,
              'r2ProfileImageUrl': presignedUrl,
              'hasCustomImage': true,
              'updatedAt': DateTime.now().toIso8601String(),
            };
            await activeDb.collection('users').update(
              where.eq('phone', userId).or(where.eq('phone', cleanPhone)).or(where.eq('username', userId)),
              {r'$set': updateDoc},
            );
            await activeDb.collection('profiles').update(
              where.eq('id', userId).or(where.eq('phone', userId)).or(where.eq('phone', cleanPhone)),
              {r'$set': updateDoc},
            );
            print("✓ [Bridge] Photo metadata updated in Atlas for user: $userId (Key: $objectKey)");
          } catch (e) {
            print("⚠ [Bridge] MongoDB metadata sync notice: $e");
          }
        }

        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({
          'success': true,
          'objectKey': objectKey,
          'profileImageKey': objectKey,
          'url': presignedUrl,
          'contentType': validation.contentType,
          'sizeBytes': imageBytes.length,
          'updatedAt': DateTime.now().toIso8601String(),
        }));
        await request.response.close();
        return;
      } catch (e) {
        request.response.statusCode = HttpStatus.internalServerError;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'error': e.toString()}));
        await request.response.close();
        return;
      }
    }

    // -------------------------------------------------------------
    // PROFILE IMAGE RETRIEVAL (GET /api/profile/image/:userId & /api/r2-image)
    // -------------------------------------------------------------
    final isProfileImageGet = (path.startsWith('/api/profile/image') || path == '/api/r2-image') &&
        (request.method == 'GET' || request.method == 'HEAD');
    if (isProfileImageGet) {
      try {
        String key = request.uri.queryParameters['key'] ?? '';
        String userId = request.uri.queryParameters['userId'] ?? '';

        if (key.isEmpty && path.startsWith('/api/profile/image/')) {
          final segment = path.replaceFirst('/api/profile/image/', '').trim();
          if (segment.isNotEmpty) userId = segment;
        }

        if (key.isEmpty && userId.isNotEmpty) {
          final cleanId = userId.replaceAll(RegExp(r'\D'), '');
          final cachedUser = _userDocCache[cleanId] ?? _userDocCache[userId];
          key = cachedUser?['profileImageKey']?.toString() ?? '';

          if (key.isEmpty) {
            try {
              var activeDb = await getDb();
              if (activeDb != null) {
                final userDoc = await activeDb.collection('users').findOne(
                  where.eq('phone', userId).or(where.eq('phone', cleanId)).or(where.eq('username', userId)),
                );
                key = userDoc?['profileImageKey']?.toString() ?? '';
                if (key.isEmpty) {
                  final profDoc = await activeDb.collection('profiles').findOne(
                    where.eq('id', userId).or(where.eq('phone', userId)).or(where.eq('phone', cleanId)),
                  );
                  key = profDoc?['profileImageKey']?.toString() ?? '';
                }
              }
            } catch (e) {
              if (e.toString().contains('No master connection')) {
                await getDb(forceReconnect: true);
              }
            }
          }

          if (key.isEmpty) {
            key = "$r2Prefix${userId.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}_avatar.jpg";
          }
        }

        if (key.isEmpty) {
          request.response.statusCode = HttpStatus.badRequest;
          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode({'error': 'userId or key parameter is required'}));
          await request.response.close();
          return;
        }

        final cleanKey = key.startsWith('/') ? key.substring(1) : key;
        final presignedUrl = generateR2PresignedUrl(cleanKey, expiresInSeconds: 604800);

        final acceptsJson = (request.headers.value('accept') ?? '').contains('application/json') ||
            request.uri.queryParameters['json'] == 'true';
        if (acceptsJson) {
          request.response.statusCode = HttpStatus.ok;
          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode({
            'success': true,
            'userId': userId,
            'objectKey': cleanKey,
            'profileImageKey': cleanKey,
            'url': presignedUrl,
            'expiresIn': 604800,
          }));
          await request.response.close();
          return;
        }

        // Direct streaming with CORS headers for Image.network & browsers
        final mime = cleanKey.toLowerCase().endsWith('.png')
            ? 'image/png'
            : (cleanKey.toLowerCase().endsWith('.webp') ? 'image/webp' : 'image/jpeg');
        request.response.headers.contentType = ContentType.parse(mime);
        request.response.headers.add('Cache-Control', 'public, max-age=86400, immutable');

        if (_imageCache.containsKey(cleanKey)) {
          final bytes = _imageCache[cleanKey]!;
          request.response.headers.contentLength = bytes.length;
          request.response.statusCode = HttpStatus.ok;
          if (request.method == 'GET') {
            request.response.add(bytes);
          }
          await request.response.close();
          return;
        }

        final r2Res = await http.get(Uri.parse(presignedUrl)).timeout(const Duration(seconds: 10));
        if (r2Res.statusCode == 200) {
          _imageCache[cleanKey] = r2Res.bodyBytes;
          request.response.headers.contentLength = r2Res.bodyBytes.length;
          request.response.statusCode = HttpStatus.ok;
          if (request.method == 'GET') {
            request.response.add(r2Res.bodyBytes);
          }
        } else {
          request.response.statusCode = r2Res.statusCode;
          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode({'error': 'Image not found in Cloudflare R2'}));
        }
      } catch (e) {
        request.response.statusCode = HttpStatus.internalServerError;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'error': e.toString()}));
      }
      await request.response.close();
      return;
    }

    // -------------------------------------------------------------
    // PROFILE IMAGE DELETION (DELETE /api/profile/image)
    // -------------------------------------------------------------
    final isProfileImageDelete = (path == '/api/profile/image' || path.startsWith('/api/profile/image/')) &&
        (request.method == 'DELETE' || request.method == 'POST');
    if (isProfileImageDelete && (request.method == 'DELETE' || request.uri.queryParameters['action'] == 'delete')) {
      try {
        String userId = request.uri.queryParameters['userId'] ?? '';
        String key = request.uri.queryParameters['key'] ?? '';

        if (userId.isEmpty && path.startsWith('/api/profile/image/')) {
          final segment = path.replaceFirst('/api/profile/image/', '').trim();
          if (segment.isNotEmpty) userId = segment;
        }

        if (userId.isEmpty) {
          try {
            final bodyStr = await utf8.decoder.bind(request).join();
            if (bodyStr.isNotEmpty) {
              final data = jsonDecode(bodyStr) as Map<String, dynamic>;
              userId = data['userId']?.toString() ?? '';
              key = data['key']?.toString() ?? '';
            }
          } catch (_) {}
        }

        if (userId.isEmpty && key.isEmpty) {
          request.response.statusCode = HttpStatus.badRequest;
          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode({'error': 'userId or key parameter is required'}));
          await request.response.close();
          return;
        }

        var activeDb = await getDb();
        if (key.isEmpty && activeDb != null) {
          try {
            final cleanPhone = userId.replaceAll(RegExp(r'\D'), '');
            final uDoc = await activeDb.collection('users').findOne(
              where.eq('phone', userId).or(where.eq('phone', cleanPhone)).or(where.eq('username', userId)),
            );
            key = uDoc?['profileImageKey']?.toString() ?? '';
            if (key.isEmpty) {
              final pDoc = await activeDb.collection('profiles').findOne(
                where.eq('id', userId).or(where.eq('phone', userId)).or(where.eq('phone', cleanPhone)),
              );
              key = pDoc?['profileImageKey']?.toString() ?? '';
            }
          } catch (e) {
            if (e.toString().contains('No master connection')) {
              await getDb(forceReconnect: true);
            }
          }
        }

        if (key.isEmpty && userId.isNotEmpty) {
          key = "$r2Prefix${userId.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}_avatar.jpg";
        }

        if (key.isNotEmpty) {
          final cleanKey = key.startsWith('/') ? key.substring(1) : key;
          await deleteFromR2(cleanKey);
          _imageCache.remove(cleanKey);
        }

        if (activeDb != null && userId.isNotEmpty) {
          try {
            final cleanPhone = userId.replaceAll(RegExp(r'\D'), '');
            final clearFields = {
              'profileImageKey': null,
              'profileImageUrl': null,
              'r2ProfileImageUrl': null,
              'hasCustomImage': false,
              'updatedAt': DateTime.now().toIso8601String(),
            };
            await activeDb.collection('users').update(
              where.eq('phone', userId).or(where.eq('phone', cleanPhone)).or(where.eq('username', userId)),
              {r'$set': clearFields},
            );
            await activeDb.collection('profiles').update(
              where.eq('id', userId).or(where.eq('phone', userId)).or(where.eq('phone', cleanPhone)),
              {r'$set': clearFields},
            );
            print("✓ [Bridge] Photo metadata cleared from Atlas for user: $userId");
          } catch (_) {}
        }

        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'success': true, 'message': 'Profile image deleted successfully'}));
        await request.response.close();
        return;
      } catch (e) {
        request.response.statusCode = HttpStatus.internalServerError;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'error': e.toString()}));
        await request.response.close();
        return;
      }
    }

    // -------------------------------------------------------------
    // DATABASE COLLECTION ENDPOINTS
    // -------------------------------------------------------------
    try {
      var activeDb = await getDb();
      if (activeDb == null) {
        request.response.statusCode = HttpStatus.serviceUnavailable;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'error': 'MongoDB Atlas unavailable'}));
        await request.response.close();
        return;
      }

      // USER COLLECTION ENDPOINTS
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

        // Cross-sync profileImageUrl to profiles collection if present
        final imgUrl = data['profileImageUrl']?.toString() ?? data['r2ProfileImageUrl']?.toString();
        if (imgUrl != null && imgUrl.isNotEmpty && phone.isNotEmpty) {
          final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
          activeDb.collection('profiles').update(
            where.eq('phone', phone).or(where.eq('phone', cleanPhone)),
            {
              r'$set': {
                'profileImageUrl': imgUrl,
                'r2ProfileImageUrl': imgUrl,
                'hasCustomImage': true,
              }
            },
          ).ignore();
        }

        final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
        if (cleanPhone.isNotEmpty) _userDocCache[cleanPhone] = data;
        if (phone.isNotEmpty) _userDocCache[phone] = data;
        if (username.isNotEmpty) _userDocCache[username.toLowerCase()] = data;

        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'success': true}));
        await request.response.close();
        return;
      }

      if (path == '/api/user' && request.method == 'GET') {
        final query = request.uri.queryParameters['query'] ?? '';
        final queryLower = query.toLowerCase();
        final clean = query.replaceAll(RegExp(r'\D'), '');

        if (_userDocCache.containsKey(clean) || _userDocCache.containsKey(queryLower) || _userDocCache.containsKey(query)) {
          final cached = _userDocCache[clean] ?? _userDocCache[queryLower] ?? _userDocCache[query];
          request.response.statusCode = HttpStatus.ok;
          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode({'success': true, 'user': cached}));
          await request.response.close();
          return;
        }

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
          }
        }

        if (doc != null) {
          final rawImg = doc['profileImageUrl']?.toString() ?? doc['r2ProfileImageUrl']?.toString();
          if (rawImg == null || rawImg.isEmpty) {
            try {
              final pDoc = await activeDb!.collection('profiles').findOne(
                where.eq('phone', clean.isNotEmpty ? clean : query),
              );
              final pImg = pDoc?['profileImageUrl']?.toString() ?? pDoc?['r2ProfileImageUrl']?.toString();
              if (pImg != null && pImg.isNotEmpty) {
                doc['profileImageUrl'] = pImg;
                doc['r2ProfileImageUrl'] = pImg;
                doc['hasCustomImage'] = true;
              }
            } catch (_) {}
          }
          if (clean.isNotEmpty) _userDocCache[clean] = doc;
          if (queryLower.isNotEmpty) _userDocCache[queryLower] = doc;
          _userDocCache[query] = doc;
        }

        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'success': true, 'user': doc}));
        await request.response.close();
        return;
      }

      // PROFILE COLLECTION ENDPOINTS
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
            final imgUrl = data['profileImageUrl']?.toString() ?? data['r2ProfileImageUrl']?.toString();
            if (userDoc != null) {
              await usersCol.update(where.id(userDoc['_id']), {
                r'$set': {
                  if (name.isNotEmpty) 'name': name,
                  if (phone.isNotEmpty) 'phone': phone,
                  if (email.isNotEmpty) 'email': email,
                  if (imgUrl != null && imgUrl.isNotEmpty) 'profileImageUrl': imgUrl,
                  if (imgUrl != null && imgUrl.isNotEmpty) 'hasCustomImage': true,
                  'updatedAt': DateTime.now().toIso8601String(),
                }
              });
            }
          } catch (_) {}
        }

        if (id.isNotEmpty) _profileDocCache[id] = data;
        if (phone.isNotEmpty) _profileDocCache[phone] = data;
        final cleanP = phone.replaceAll(RegExp(r'\D'), '');
        if (cleanP.isNotEmpty) _profileDocCache[cleanP] = data;

        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'success': true}));
        await request.response.close();
        return;
      }

      if (path == '/api/profile' && request.method == 'GET') {
        final query = request.uri.queryParameters['query'] ?? '';
        final clean = query.replaceAll(RegExp(r'\D'), '');

        if (_profileDocCache.containsKey(clean) || _profileDocCache.containsKey(query)) {
          final cached = _profileDocCache[clean] ?? _profileDocCache[query];
          request.response.statusCode = HttpStatus.ok;
          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode({'success': true, 'profile': cached}));
          await request.response.close();
          return;
        }

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
            }
          }
        }

        if (doc != null) {
          final rawImg = doc['profileImageUrl']?.toString() ?? doc['r2ProfileImageUrl']?.toString();
          if (rawImg == null || rawImg.isEmpty) {
            try {
              final uDoc = await activeDb!.collection('users').findOne(
                where.eq('phone', clean.isNotEmpty ? clean : query),
              );
              final uImg = uDoc?['profileImageUrl']?.toString() ?? uDoc?['r2ProfileImageUrl']?.toString();
              if (uImg != null && uImg.isNotEmpty) {
                doc['profileImageUrl'] = uImg;
                doc['r2ProfileImageUrl'] = uImg;
                doc['hasCustomImage'] = true;
              }
            } catch (_) {}
          }
          if (clean.isNotEmpty) _profileDocCache[clean] = doc;
          _profileDocCache[query] = doc;
          if (doc['id'] != null) _profileDocCache[doc['id'].toString()] = doc;
        }

        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'success': true, 'profile': doc}));
        await request.response.close();
        return;
      }

      // SHORTLIST COLLECTION ENDPOINTS
      if (path == '/api/shortlist' && request.method == 'GET') {
        final userId = request.uri.queryParameters['userId'] ?? '';
        final userPhone = request.uri.queryParameters['userPhone'] ?? '';
        final cleanPhone = userPhone.replaceAll(RegExp(r'\D'), '');

        if (_shortlistDocCache.containsKey(userId) || _shortlistDocCache.containsKey(cleanPhone) || _shortlistDocCache.containsKey(userPhone)) {
          final cached = _shortlistDocCache[userId] ?? _shortlistDocCache[cleanPhone] ?? _shortlistDocCache[userPhone];
          request.response.statusCode = HttpStatus.ok;
          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode({'success': true, 'shortlist': cached}));
          await request.response.close();
          return;
        }

        final shortlistsCol = activeDb.collection('shortlists');
        Map<String, dynamic>? doc;
        if (userId.isNotEmpty) {
          doc = await shortlistsCol.findOne(where.eq('userId', userId));
        }
        if (doc == null && cleanPhone.isNotEmpty) {
          doc = await shortlistsCol.findOne(where.eq('userPhone', cleanPhone));
          doc ??= await shortlistsCol.findOne(where.eq('userPhone', userPhone));
        }

        if (doc != null) {
          if (userId.isNotEmpty) _shortlistDocCache[userId] = doc;
          if (cleanPhone.isNotEmpty) _shortlistDocCache[cleanPhone] = doc;
          if (userPhone.isNotEmpty) _shortlistDocCache[userPhone] = doc;
        }

        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'success': true, 'shortlist': doc}));
        await request.response.close();
        return;
      }

      if (path == '/api/shortlist' && request.method == 'POST') {
        final bodyStr = await utf8.decoder.bind(request).join();
        final data = jsonDecode(bodyStr) as Map<String, dynamic>;
        final userId = data['userId']?.toString() ?? '';
        final userPhone = data['userPhone']?.toString() ?? '';
        final cleanPhone = userPhone.replaceAll(RegExp(r'\D'), '');

        if (userId.isNotEmpty) _shortlistDocCache[userId] = data;
        if (cleanPhone.isNotEmpty) _shortlistDocCache[cleanPhone] = data;
        if (userPhone.isNotEmpty) _shortlistDocCache[userPhone] = data;

        final shortlistsCol = activeDb.collection('shortlists');
        final selector = userId.isNotEmpty
            ? where.eq('userId', userId)
            : (cleanPhone.isNotEmpty ? where.eq('userPhone', cleanPhone) : where.eq('userPhone', userPhone));
        await shortlistsCol.update(selector, {r'$set': data}, upsert: true);
        print("✓ [Bridge] Shortlist updated in Atlas for user: $userId (count: ${(data['profileIds'] as List?)?.length})");

        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'success': true}));
        await request.response.close();
        return;
      }

      // PAYMENTS COLLECTION ENDPOINTS
      if (path == '/api/payments' && request.method == 'GET') {
        final userId = request.uri.queryParameters['userId'] ?? '';
        final userPhone = request.uri.queryParameters['userPhone'] ?? '';
        final cleanPhone = userPhone.replaceAll(RegExp(r'\D'), '');
        final cacheKey = userId.isNotEmpty ? userId : (cleanPhone.isNotEmpty ? cleanPhone : 'all');

        if (_paymentsDocCache.containsKey(cacheKey)) {
          request.response.statusCode = HttpStatus.ok;
          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode({'success': true, 'payments': _paymentsDocCache[cacheKey]}));
          await request.response.close();
          return;
        }

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

        _paymentsDocCache[cacheKey] = docs;

        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'success': true, 'payments': docs}));
        await request.response.close();
        return;
      }

      if (path == '/api/payment' && request.method == 'POST') {
        final bodyStr = await utf8.decoder.bind(request).join();
        final data = jsonDecode(bodyStr) as Map<String, dynamic>;
        final id = data['id']?.toString() ?? '';
        final status = data['status']?.toString() ?? 'pending';

        final paymentsCol = activeDb.collection('payments');
        await paymentsCol.update(where.eq('id', id), {r'$set': data}, upsert: true);
        print("✓ [Bridge] Payment stored/updated in Atlas: $id (Status: $status)");

        if (status == 'approved' && data['profileIds'] is List) {
          final profilesCol = activeDb.collection('profiles');
          for (final pid in (data['profileIds'] as List)) {
            await profilesCol.update(
              where.eq('id', pid.toString()),
              {r'$set': {'isContactUnlocked': true, 'isHoroscopeUnlocked': true}},
              upsert: false,
            );
          }
        }

        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'success': true}));
        await request.response.close();
        return;
      }

      if (path == '/api/profiles' && request.method == 'GET') {
        final profilesCol = activeDb.collection('profiles');
        final docs = await profilesCol.find().toList();
        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'success': true, 'profiles': docs}));
        await request.response.close();
        return;
      }

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

        final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
        final profilesCol = activeDb.collection('profiles');
        dynamic selector;
        if (id.isNotEmpty && cleanPhone.isNotEmpty) {
          selector = where.eq('id', id).or(where.eq('phone', cleanPhone)).or(where.eq('phone', phone));
        } else if (id.isNotEmpty) {
          selector = where.eq('id', id);
        } else if (cleanPhone.isNotEmpty) {
          selector = where.eq('phone', cleanPhone).or(where.eq('phone', phone));
        } else {
          request.response.statusCode = HttpStatus.badRequest;
          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode({'error': 'Profile id or phone required for deletion'}));
          await request.response.close();
          return;
        }

        final result = await profilesCol.remove(selector);
        print("✓ [Bridge] Profile deleted from Atlas: id=$id, phone=$phone, result=$result");

        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'success': true, 'deleted': id.isNotEmpty ? id : phone}));
        await request.response.close();
        return;
      }

      // Default 404
      request.response.statusCode = HttpStatus.notFound;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({'error': 'Endpoint not found', 'path': path}));
      await request.response.close();
    } catch (e) {
      print("Bridge request error: $e");
      try {
        request.response.statusCode = HttpStatus.internalServerError;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'error': e.toString()}));
        await request.response.close();
      } catch (_) {}
    }
  });
}
