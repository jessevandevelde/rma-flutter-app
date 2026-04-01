import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class Authenticatie {
  late final Dio _dio;

  Authenticatie() {
    // Dynamische baseUrl op basis van platform
    String baseUrl = 'http://127.0.0.1:8000';

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final token = data['access_token'] ?? data['token'];

        dynamic userTypeId;
        if (data['user'] != null) {
          userTypeId = data['user']['user_type_id'];
        } else if (data['user_type_id'] != null) {
          userTypeId = data['user_type_id'];
        }

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          if (userTypeId != null) {
            await prefs.setInt('user_type_id', int.parse(userTypeId.toString()));
          }
        }
      }

      return response;
    } on DioException catch (e) {
      if (e.response != null) return e.response;
      rethrow;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<int?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_type_id');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_type_id');
  }

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
      return e.response;
    }
  }
}