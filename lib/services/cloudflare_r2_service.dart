import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Cloudflare R2 S3-compatible Storage Service
/// Connected to bucket: matrimony-profile-images
class CloudflareR2Service {
  static final CloudflareR2Service _instance = CloudflareR2Service._internal();
  factory CloudflareR2Service() => _instance;
  CloudflareR2Service._internal();

  // Cloudflare R2 Credentials
  static const String accountApiToken =
      String.fromEnvironment('CLOUDFLARE_R2_ACCOUNT_API_TOKEN', defaultValue: '');
  static const String accessKeyId = "16fa39f1d2e94ee5405a9995244691f0";
  static const String secretAccessKey =
      "06dfc88dcbf86cb0174233ab6670274da20d30de78383b87d2c3d08a736e1bd3";
  static const String endpoint =
      "https://b535b7c908a09f10d27773b1b9536777.r2.cloudflarestorage.com";
  static const String bucketName = "matrimony-profile-images";
  static const String region = "auto";
  static const String host =
      "b535b7c908a09f10d27773b1b9536777.r2.cloudflarestorage.com";

  /// Set to true during test executions to avoid writing dummy files to live R2 bucket
  static bool isTestMode = const bool.fromEnvironment('FLUTTER_TEST');

  /// Uploads user profile image to Cloudflare R2.
  /// Uses a clean, single dedicated key per user (`profiles/{userId}_avatar.ext`)
  /// so old photos are replaced and no duplicate/junk images accumulate.
  /// Returns a presigned GET URL that works seamlessly even when Public Access is disabled on R2.
  Future<String> uploadProfileImage({
    required Uint8List imageBytes,
    required String fileName,
    String? userId,
    String? oldImageUrl,
    String contentType = "image/jpeg",
  }) async {
    // Clean identifier for deterministic single-image per user
    final cleanId = (userId != null && userId.trim().isNotEmpty)
        ? userId.trim().toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')
        : fileName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

    final String ext = fileName.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
    final String cleanContentType = ext == 'png' ? "image/png" : contentType;
    final String objectKey = "profiles/${cleanId}_avatar.$ext";

    // In unit/widget tests, do not spam live Cloudflare R2 bucket with dummy test strings
    if (isTestMode) {
      return generatePresignedGetUrl(objectKey);
    }

    // If a previous distinct object URL exists in this bucket, clean it up
    if (oldImageUrl != null && oldImageUrl.contains(bucketName)) {
      try {
        final oldKey = extractObjectKey(oldImageUrl);
        if (oldKey != null && oldKey != objectKey) {
          await deleteObject(oldKey);
        }
      } catch (_) {}
    }

    bool uploadedSuccessfully = false;

    // 1. First attempt: Upload via Web Bridge (works reliably on Chrome/Web without browser CORS or forbidden 'Host' header)
    try {
      final bridgeUri = Uri.parse("http://127.0.0.1:8765/api/r2-upload");
      final bridgeResponse = await http.post(
        bridgeUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'objectKey': objectKey,
          'imageBase64': base64Encode(imageBytes),
          'contentType': cleanContentType,
          'userId': userId ?? '',
        }),
      ).timeout(const Duration(seconds: 15));

      if (bridgeResponse.statusCode == 200) {
        final data = jsonDecode(bridgeResponse.body);
        if (data['success'] == true) {
          uploadedSuccessfully = true;
          if (kDebugMode) {
            print("✓ [Cloudflare R2] Successfully uploaded to R2 via Web Bridge: $objectKey");
          }
          if (data['url'] != null && data['url'].toString().isNotEmpty) {
            return data['url'].toString();
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("ℹ [Cloudflare R2] Bridge upload attempt: $e (trying direct S3 if native)");
      }
    }

    // 2. Direct S3 SigV4 PUT fallback (for native mobile platforms or direct TCP)
    if (!uploadedSuccessfully && !kIsWeb) {
      final Uri uri = Uri.parse("$endpoint/$bucketName/$objectKey");
      final DateTime now = DateTime.now().toUtc();
      final String amzDate = _formatDateTime(now);
      final String dateStamp = _formatDate(now);
      final String payloadHash = sha256.convert(imageBytes).toString();

      final String canonicalUri = "/$bucketName/$objectKey";
      const String canonicalQueryString = "";
      final String canonicalHeaders =
          "host:$host\nx-amz-content-sha256:$payloadHash\nx-amz-date:$amzDate\n";
      const String signedHeaders = "host;x-amz-content-sha256;x-amz-date";
      final String canonicalRequest =
          "PUT\n$canonicalUri\n$canonicalQueryString\n$canonicalHeaders\n$signedHeaders\n$payloadHash";

      const String algorithm = "AWS4-HMAC-SHA256";
      final String credentialScope = "$dateStamp/$region/s3/aws4_request";
      final String stringToSign =
          "$algorithm\n$amzDate\n$credentialScope\n${sha256.convert(utf8.encode(canonicalRequest))}";

      final List<int> signingKey = _getSignatureKey(secretAccessKey, dateStamp, region, "s3");
      final String signature = Hmac(sha256, signingKey).convert(utf8.encode(stringToSign)).toString();

      final String authorizationHeader =
          "$algorithm Credential=$accessKeyId/$credentialScope, SignedHeaders=$signedHeaders, Signature=$signature";

      try {
        final response = await http.put(
          uri,
          headers: {
            'Host': host,
            'Content-Type': cleanContentType,
            'x-amz-date': amzDate,
            'x-amz-content-sha256': payloadHash,
            'Authorization': authorizationHeader,
          },
          body: imageBytes,
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200 || response.statusCode == 204) {
          uploadedSuccessfully = true;
          if (kDebugMode) {
            print("✓ [Cloudflare R2] Profile image saved to R2 via direct S3: ${response.statusCode} -> $objectKey");
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("⚠ [Cloudflare R2] Direct S3 upload exception: $e");
        }
      }
    }

    if (!uploadedSuccessfully && !isTestMode) {
      throw Exception("Cloudflare R2-ல் படத்தை பதிவேற்ற முடியவில்லை. Web Bridge (port 8765) இயக்கத்தில் உள்ளதா என சரிபார்க்கவும்.");
    }

    return generatePresignedGetUrl(objectKey);
  }

  /// Generates an AWS S3 SigV4 Presigned GET URL with 7 days expiration.
  /// Allows browsers and mobile apps to display images directly from private R2 buckets.
  String generatePresignedGetUrl(String objectKey, {int expiresInSeconds = 604800}) {
    final cleanKey = objectKey.startsWith('/') ? objectKey.substring(1) : objectKey;
    final now = DateTime.now().toUtc();
    final amzDate = _formatDateTime(now);
    final dateStamp = _formatDate(now);

    const algorithm = "AWS4-HMAC-SHA256";
    final credentialScope = "$dateStamp/$region/s3/aws4_request";
    final credential = Uri.encodeComponent("$accessKeyId/$credentialScope");
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

    final canonicalUri = "/$bucketName/$cleanKey";
    final canonicalHeaders = "host:$host\n";
    const payloadHash = "UNSIGNED-PAYLOAD";

    final canonicalRequest =
        "GET\n$canonicalUri\n$canonicalQueryString\n$canonicalHeaders\n$signedHeaders\n$payloadHash";

    final stringToSign =
        "$algorithm\n$amzDate\n$credentialScope\n${sha256.convert(utf8.encode(canonicalRequest))}";

    final signingKey = _getSignatureKey(secretAccessKey, dateStamp, region, "s3");
    final signature = Hmac(sha256, signingKey).convert(utf8.encode(stringToSign)).toString();

    return "$endpoint/$bucketName/$cleanKey?$canonicalQueryString&X-Amz-Signature=$signature";
  }

  /// Optional Public Domain for Cloudflare R2 bucket (e.g. pub-xxxxxx.r2.dev or custom domain).
  /// If set, direct public CDN URLs are used instead of presigned URLs or localhost bridge.
  static const String publicDomain =
      String.fromEnvironment('CLOUDFLARE_R2_PUBLIC_DOMAIN', defaultValue: '');

  /// Ensures any stored R2 URL has a fresh valid signature for display.
  String ensureDisplayableUrl(String? rawUrlOrKey) {
    if (rawUrlOrKey == null || rawUrlOrKey.trim().isEmpty) return '';
    final trimmed = rawUrlOrKey.trim();

    // If it is already a direct bridge URL on Web, return it as-is (do not re-wrap)
    if (kIsWeb && (trimmed.contains('127.0.0.1:8765/api/r2-image') || trimmed.contains('localhost:8765/api/r2-image'))) {
      return trimmed;
    }

    final key = extractObjectKey(trimmed);
    if (key != null && key.isNotEmpty) {
      // If a public domain is enabled on Cloudflare R2, use fast direct CDN URL
      if (publicDomain.isNotEmpty) {
        final cleanBase = publicDomain.endsWith('/')
            ? publicDomain.substring(0, publicDomain.length - 1)
            : publicDomain;
        return "$cleanBase/$key";
      }
      if (kIsWeb) {
        return "http://127.0.0.1:8765/api/r2-image?key=$key";
      }
      return generatePresignedGetUrl(key);
    }

    return trimmed;
  }

  /// Extracts the object key from a full Cloudflare R2 URL, bridge URL, or relative path
  String? extractObjectKey(String urlOrKey) {
    final trimmed = urlOrKey.trim();
    if (trimmed.isEmpty) return null;

    // 1. If it's already a bridge URL with key param, extract clean key:
    if (trimmed.contains('/api/r2-image')) {
      try {
        final uri = Uri.parse(trimmed);
        final paramKey = uri.queryParameters['key'];
        if (paramKey != null && paramKey.isNotEmpty) {
          return paramKey.startsWith('/') ? paramKey.substring(1) : paramKey;
        }
      } catch (_) {}
    }

    // 2. If it's already a relative path:
    if (!trimmed.startsWith('http')) {
      return trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    }

    // 3. If it's a full URL:
    try {
      final uri = Uri.parse(trimmed);
      final segments = uri.pathSegments;
      final bucketIdx = segments.indexOf(bucketName);
      if (bucketIdx != -1 && bucketIdx + 1 < segments.length) {
        return segments.sublist(bucketIdx + 1).join('/');
      }
      // If public domain or r2.dev host
      if (uri.host.contains('r2.cloudflarestorage.com') ||
          uri.host.contains('r2.dev') ||
          (publicDomain.isNotEmpty && uri.host.contains(Uri.tryParse(publicDomain)?.host ?? ''))) {
        return uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;
      }
      if (trimmed.contains('profiles/')) {
        final idx = trimmed.indexOf('profiles/');
        final endIdx = trimmed.indexOf('?', idx);
        return endIdx != -1 ? trimmed.substring(idx, endIdx) : trimmed.substring(idx);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Deletes an object from Cloudflare R2
  Future<bool> deleteObject(String objectKey) async {
    final cleanKey = objectKey.startsWith('/') ? objectKey.substring(1) : objectKey;
    final now = DateTime.now().toUtc();
    final amzDate = _formatDateTime(now);
    final dateStamp = _formatDate(now);

    final payloadHash = sha256.convert(utf8.encode("")).toString();
    final canonicalUri = "/$bucketName/$cleanKey";
    const canonicalQueryString = "";
    final canonicalHeaders =
        "host:$host\nx-amz-content-sha256:$payloadHash\nx-amz-date:$amzDate\n";
    const signedHeaders = "host;x-amz-content-sha256;x-amz-date";

    final canonicalRequest =
        "DELETE\n$canonicalUri\n$canonicalQueryString\n$canonicalHeaders\n$signedHeaders\n$payloadHash";

    const algorithm = "AWS4-HMAC-SHA256";
    final credentialScope = "$dateStamp/$region/s3/aws4_request";
    final stringToSign =
        "$algorithm\n$amzDate\n$credentialScope\n${sha256.convert(utf8.encode(canonicalRequest))}";

    final signingKey = _getSignatureKey(secretAccessKey, dateStamp, region, "s3");
    final signature = Hmac(sha256, signingKey).convert(utf8.encode(stringToSign)).toString();

    final authorizationHeader =
        "$algorithm Credential=$accessKeyId/$credentialScope, SignedHeaders=$signedHeaders, Signature=$signature";

    try {
      final uri = Uri.parse("$endpoint/$bucketName/$cleanKey");
      final res = await http.delete(uri, headers: {
        'Host': host,
        'x-amz-date': amzDate,
        'x-amz-content-sha256': payloadHash,
        'Authorization': authorizationHeader,
      }).timeout(const Duration(seconds: 5));
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      if (kDebugMode) print("⚠ [Cloudflare R2] Delete failed for $cleanKey: $e");
      return false;
    }
  }

  /// AWS SigV4 Helper methods
  static String _formatDateTime(DateTime dt) {
    return "${_formatDate(dt)}T"
        "${dt.hour.toString().padLeft(2, '0')}"
        "${dt.minute.toString().padLeft(2, '0')}"
        "${dt.second.toString().padLeft(2, '0')}Z";
  }

  static String _formatDate(DateTime dt) {
    return "${dt.year.toString().padLeft(4, '0')}"
        "${dt.month.toString().padLeft(2, '0')}"
        "${dt.day.toString().padLeft(2, '0')}";
  }

  static List<int> _getSignatureKey(String key, String dateStamp, String regionName, String serviceName) {
    final kDate = Hmac(sha256, utf8.encode("AWS4$key")).convert(utf8.encode(dateStamp)).bytes;
    final kRegion = Hmac(sha256, kDate).convert(utf8.encode(regionName)).bytes;
    final kService = Hmac(sha256, kRegion).convert(utf8.encode(serviceName)).bytes;
    final kSigning = Hmac(sha256, kService).convert(utf8.encode("aws4_request")).bytes;
    return kSigning;
  }
}
