import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class Authenticatie {
  late final Dio _dio;

  Authenticatie() {
    // We gaan terug naar de basisinstelling die voorheen werkte.
    const String baseUrl = 'http://localhost:8000';

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
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
      // We geven de response terug als die er is, anders gooien we de error door
      if (e.response != null) return e.response;
      rethrow;
    }
  }
}
