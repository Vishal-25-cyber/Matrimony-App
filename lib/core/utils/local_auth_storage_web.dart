// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;

/// Web (Chrome / Edge / Firefox) persistent storage using HTML5 localStorage
class LocalAuthStorage {
  static const String _key = 'pandarathar_matrimony_user_accounts';
  static const String _testKey = 'pandarathar_matrimony_user_accounts_test';

  static String get _activeKey {
    if (const bool.fromEnvironment('FLUTTER_TEST')) {
      return _testKey;
    }
    return _key;
  }

  static Future<void> clearAllUsers() async {
    try {
      html.window.localStorage.remove(_activeKey);
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

      html.window.localStorage[_activeKey] = jsonEncode(existing);
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> loadAllUsers() async {
    try {
      final text = html.window.localStorage[_activeKey];
      if (text != null && text.isNotEmpty) {
        final decoded = jsonDecode(text);
        if (decoded is List) {
          return decoded
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
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
