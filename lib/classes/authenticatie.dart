import 'dart:io'; // Nodig om te checken of we op Android zitten
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Voor kIsWeb

class Authenticatie {
  late final Dio _dio;

  Authenticatie() {
    const String mode = String.fromEnvironment('APP_MODE', defaultValue: 'dev');
    String baseUrl;

    if (mode == 'prod') {
      baseUrl = 'https://api.jouwproductieurl.com';
    } else {
      // UITLEG: Voor Android emulators moet je 10.0.2.2 gebruiken in plaats van localhost (127.0.0.1)
      if (!kIsWeb && Platform.isAndroid) {
        baseUrl = 'http://10.0.2.2:8000';
      } else {
        baseUrl = 'http://127.0.0.1:8000';
      }
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
      debugPrint('Backend verbonden! Status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      debugPrint('GEEN verbinding met backend op ${_dio.options.baseUrl}');
      debugPrint('Foutmelding: ${e.message}');
      return e.response;
    }
  }
}
