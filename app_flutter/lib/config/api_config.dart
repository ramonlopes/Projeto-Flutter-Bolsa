import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiConfig {
  static const String _defined = String.fromEnvironment('API_BASE_URL');
  static String get baseUrl {
    if (_defined.isNotEmpty) return _defined;
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://192.168.10.18:3000'; // IP DO PC
    return 'http://localhost:3000'; // Windows, macOS, iOS simulador
  }

  static String get usuarios => '$baseUrl/usuarios';
  static String get acoes => '$baseUrl/acoes';
}