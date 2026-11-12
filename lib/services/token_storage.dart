import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _key = 'auth_token';

  static Future<String?> read() async =>
      (await SharedPreferences.getInstance()).getString(_key);

  static Future<void> save(String token) async =>
      (await SharedPreferences.getInstance()).setString(_key, token);

  static Future<void> clear() async =>
      (await SharedPreferences.getInstance()).remove(_key);
}

