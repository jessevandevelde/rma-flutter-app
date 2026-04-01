import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Authenticatie {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Authenticatie() {
    // Gebruik 10.0.2.2 voor Android Emulator, localhost voor Windows/Web
    String baseUrl = 'http://localhost:8000';
    if (!kIsWeb && Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:8000';
    }

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Voeg een interceptor toe om de token automatisch aan elke request toe te voegen
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
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

      // Sla de token op als de login succesvol is
      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['access_token'] ?? response.data['token'];
        if (token != null) {
          await _storage.write(key: 'auth_token', value: token);
          debugPrint('Token succesvol opgeslagen');
        }
      }

      return response;
    } on DioException catch (e) {
      debugPrint('Login fout: ${e.message}');
      // We geven de response terug als die er is, anders gooien we de error door
      if (e.response != null) return e.response;
      rethrow;
    }
  }

  /// Haal de opgeslagen token op
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// Log de gebruiker uit en verwijder de token
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  /// Stuurt een wachtwoord reset link naar de opgegeven email
  Future<Response?> forgotPassword(String email) async {
    try {
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
