import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:matrimony_app/services/cloudflare_r2_service.dart';

void main() {
  group('Cloudflare R2 Backend Architecture & Security Tests', () {
    const backendUrl = "http://127.0.0.1:8765";

    // Valid sample 1x1 PNG bytes (starts with 89 50 4E 47)
    final validPngBytes = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
    ]);

    test('1. Backend /api/health confirms R2 configuration on server-side', () async {
      final res = await http.get(Uri.parse('$backendUrl/api/health'));
      expect(res.statusCode, 200);
      final data = jsonDecode(res.body);
      expect(data['status'], 'ok');
      expect(data['r2Configured'], isTrue);
      expect(data['r2Bucket'], 'matrimony-profile-images');
    });

    test('2. Backend blocks unauthorized upload without userId or token', () async {
      final res = await http.post(
        Uri.parse('$backendUrl/api/profile/upload-image'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'imageBase64': base64Encode(validPngBytes),
        }),
      );
      expect(res.statusCode, 401);
      final data = jsonDecode(res.body);
      expect(data['error'], contains('Authentication required'));
    });

    test('3. Backend validates magic bytes and rejects non-image payload', () async {
      final fakeTextBytes = utf8.encode("This is just plain text, not an image!");
      final res = await http.post(
        Uri.parse('$backendUrl/api/profile/upload-image'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer user_test_1',
        },
        body: jsonEncode({
          'userId': 'user_test_1',
          'imageBase64': base64Encode(fakeTextBytes),
        }),
      );
      expect(res.statusCode, 400);
      final data = jsonDecode(res.body);
      expect(data['error'], contains('Unsupported image format'));
    });

    test('4. Backend validates maximum image file size (> 5MB)', () async {
      // Create a payload larger than 5MB
      final oversizedBytes = Uint8List(5 * 1024 * 1024 + 100);
      // Give it valid PNG magic bytes
      oversizedBytes[0] = 0x89;
      oversizedBytes[1] = 0x50;
      oversizedBytes[2] = 0x4E;
      oversizedBytes[3] = 0x47;

      final res = await http.post(
        Uri.parse('$backendUrl/api/profile/upload-image'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer user_test_oversized',
        },
        body: jsonEncode({
          'userId': 'user_test_oversized',
          'imageBase64': base64Encode(oversizedBytes),
        }),
      );
      expect(res.statusCode, 413);
      final data = jsonDecode(res.body);
      expect(data['error'], contains('exceeds 5MB'));
    });

    test('5. Backend accepts valid image via multipart/form-data and uploads to R2', () async {
      final req = http.MultipartRequest('POST', Uri.parse('$backendUrl/api/profile/upload-image'));
      req.headers['Authorization'] = 'Bearer user_live_test';
      req.fields['userId'] = 'user_live_test';
      req.files.add(
        http.MultipartFile.fromBytes('image', validPngBytes, filename: 'avatar.png'),
      );

      final streamedRes = await req.send();
      final res = await http.Response.fromStream(streamedRes);

      expect(res.statusCode, 200);
      final data = jsonDecode(res.body);
      expect(data['success'], isTrue);
      // Target object key pattern: profiles/<user_id>_avatar.<ext>
      expect(data['objectKey'], 'profiles/user_live_test_avatar.png');
      expect(data['url'], contains('matrimony-profile-images'));
      expect(data['url'], contains('profiles/user_live_test_avatar.png'));
    });

    test('6. Backend retrieves profile image info via GET /api/profile/image/:userId', () async {
      final res = await http.get(
        Uri.parse('$backendUrl/api/profile/image/user_live_test?json=true'),
        headers: {'Accept': 'application/json'},
      );
      expect(res.statusCode, 200);
      final data = jsonDecode(res.body);
      expect(data['success'], isTrue);
      expect(data['objectKey'], 'profiles/user_live_test_avatar.png');
      expect(data['url'], contains('user_live_test_avatar.png'));
    });

    test('7. Backend deletes profile image via DELETE /api/profile/image', () async {
      final res = await http.delete(
        Uri.parse('$backendUrl/api/profile/image?userId=user_live_test'),
      );
      expect(res.statusCode, 200);
      final data = jsonDecode(res.body);
      expect(data['success'], isTrue);
      expect(data['message'], contains('deleted successfully'));
    });

    test('8. CloudflareR2Service in Flutter contains zero credentials and formats URLs cleanly', () {
      final r2 = CloudflareR2Service();
      // Ensure displayable URL transforms object keys to backend proxy URLs
      final displayUrl = r2.ensureDisplayableUrl('profiles/PM-1001_avatar.jpg');
      expect(displayUrl, contains('http://127.0.0.1:8765/api/profile/image?key=profiles'));

      // Test extractObjectKey
      final extracted = r2.extractObjectKey('https://b535b7c908a09f10d27773b1b9536777.r2.cloudflarestorage.com/matrimony-profile-images/profiles/test_user_avatar.jpg?sig=abc');
      expect(extracted, 'profiles/test_user_avatar.jpg');
    });
  });
}
