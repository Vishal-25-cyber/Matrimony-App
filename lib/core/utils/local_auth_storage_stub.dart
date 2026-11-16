import 'dart:convert';
import 'dart:io';

/// Native (Windows / Android / iOS / Desktop) persistent storage for registered user credentials
class LocalAuthStorage {
  static const String _fileName = '.user_credentials_cache.json';
  static const String _testFileName = '.user_credentials_cache_test.json';

  static File get _file {
    if (const bool.fromEnvironment('FLUTTER_TEST')) {
      return File(_testFileName);
    }
    return File(_fileName);
  }

  static Future<void> clearAllUsers() async {
    try {
      if (await _file.exists()) {
        await _file.delete();
      }
    } catch (_) {}
  }

  static Future<void> saveUser(Map<String, dynamic> userData) async {
    try {
      final existing = await loadAllUsers();
      final phone = userData['phone']?.toString().replaceAll(RegExp(r'\D'), '') ?? '';
      final username = userData['username']?.toString().toLowerCase() ?? '';

      final idx = existing.indexWhere((u) {
        final uPhone = u['phone']?.toString().replaceAll(RegExp(r'\D'), '') ?? '';
        final uUsername = u['username']?.toString().toLowerCase() ?? '';
        return (phone.isNotEmpty && uPhone == phone) ||
            (username.isNotEmpty && uUsername == username);
      });

      if (idx != -1) {
        existing[idx] = userData;
      } else {
        existing.add(userData);
      }

      await _file.writeAsString(jsonEncode(existing));
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> loadAllUsers() async {
    try {
      if (await _file.exists()) {
        final text = await _file.readAsString();
        if (text.isNotEmpty) {
          final decoded = jsonDecode(text);
          if (decoded is List) {
            return decoded
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
          }
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>?> findUser(String credential) async {
    final credLower = credential.trim().toLowerCase();
    final cleanPhone = credential.replaceAll(RegExp(r'\D'), '');

    final all = await loadAllUsers();
    for (final u in all) {
      final uPhone = u['phone']?.toString().replaceAll(RegExp(r'\D'), '') ?? '';
      final uUsername = u['username']?.toString().toLowerCase() ?? '';
      final uEmail = u['email']?.toString().toLowerCase() ?? '';

      if ((cleanPhone.isNotEmpty && uPhone == cleanPhone) ||
          (cleanPhone.isNotEmpty && cleanPhone.endsWith(uPhone)) ||
          (uPhone.isNotEmpty && uPhone.endsWith(cleanPhone)) ||
          uUsername == credLower ||
          uEmail == credLower) {
        return u;
      }
    }
    return null;
  }
}
