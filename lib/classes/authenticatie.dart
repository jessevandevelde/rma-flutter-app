import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class Authenticatie {
  late final Dio _dio;

  Authenticatie() {
    // Dynamische baseUrl op basis van platform
    String baseUrl = 'http://localhost:8000';
    
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        // 10.0.2.2 is voor Android Emulators om de host machine te bereiken
        baseUrl = 'http://10.0.2.2:8000';
      }
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
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
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
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          debugPrint('Token succesvol opgeslagen via SharedPreferences');
        }
      }

      return response;
    } on DioException catch (e) {
      debugPrint('Login fout: ${e.message}');
      if (e.response != null) return e.response;
      rethrow;
    }
  }

  /// Haal de opgeslagen token op
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Log de gebruiker uit en verwijder de token
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
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
