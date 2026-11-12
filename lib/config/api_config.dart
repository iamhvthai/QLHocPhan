import 'package:flutter/foundation.dart';

class ApiConfig {
  // Máy ảo Android: 10.0.2.2 trỏ về localhost của máy tính.
  // Điện thoại thật: đổi thành IP LAN, ví dụ 'http://192.168.1.10:3000/api'.
  static const String _lanOverride = '';

  static String get baseUrl {
    if (_lanOverride.isNotEmpty) return _lanOverride;
    if (kIsWeb) return 'http://localhost:3000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }
}

