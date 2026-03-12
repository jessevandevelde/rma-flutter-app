import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class Authenticatie {
  late final Dio _dio;

  Authenticatie() {
    // Haal de APP_MODE op (bijv. via --dart-define=APP_MODE=prod)
    const String mode = String.fromEnvironment('APP_MODE', defaultValue: 'development');

    // Bepaal de baseUrl op basis van de modus
    String baseUrl;
    if (mode == 'production') {
      baseUrl = '';
    } else if (mode == 'staging') {
      baseUrl = '';
    } else {
      // Gebruik 10.0.2.2 voor Android emulators of 127.0.0.1 voor iOS/Web
      baseUrl = 'http://10.0.2.2:8000  ';
    }

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5), // Iets ruimer gezet voor stabiliteit
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    debugPrint('Authenticatie geinitialiseerd op: $baseUrl');
  }

  Future<Response?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return response;
    } on DioException catch (e) {
      debugPrint('Login fout: ${e.message}');
      return e.response;
    }
  }
}
