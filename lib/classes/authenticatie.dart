import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class Authenticatie {
  late final Dio _dio;

  Authenticatie() {
    // Haal de APP_MODE op (bijv. via --dart-define=APP_MODE=prod)
    const String mode = String.fromEnvironment('APP_MODE', defaultValue: 'dev');

    // Bepaal de baseUrl op basis van de modus
    String baseUrl;
    if (mode == 'prod') {
      baseUrl = 'https://api.jouwproductieurl.com';
    } else if (mode == 'staging') {
      baseUrl = 'https://api.staging.com';
    } else {
      // Gebruik 10.0.2.2 voor Android emulators of 127.0.0.1 voor iOS/Web
      baseUrl = 'http://127.0.0.1:8000';
    }

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
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

  /// Stuurt een wachtwoord reset link naar de opgegeven email
  Future<Response?> forgotPassword(String email) async {
    try {
      // We gebruiken '/forgot-password' omdat dit de route is die je server bereikte.
      // Zorg ervoor dat er geen spaties in de string staan.
      final response = await _dio.post(
        '/forgot-password',
        data: {
          'email': email,
        },
      );
      return response;
    } on DioException catch (e) {
      debugPrint('Forgot password fout: ${e.message}');
      return e.response;
    }
  }
}
