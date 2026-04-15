import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authenticatie {
  late final Dio _dio;

  Authenticatie() {
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
        final prefs = await SharedPreferences.getInstance();

        final user = data['user'] ?? data;
        
        if (user != null) {
          await prefs.setInt('user_id', int.tryParse(user['id']?.toString() ?? '') ?? 0);
          await prefs.setString('user_email', user['email'] ?? '');
          await prefs.setString('user_name', user['first_name'] ?? '');
          
          final dynamic typeId = user['user_type_id'] ?? user['role_id'] ?? user['level'];
          await prefs.setInt('user_type_id', int.tryParse(typeId?.toString() ?? '1') ?? 1);
        }

        final token = data['access_token'] ?? data['token'];
        if (token != null) {
          await prefs.setString('auth_token', token.toString());
        }
      }
      return response;
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  Future<int?> getUserTypeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_type_id');
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<Response?> forgotPassword(String email) async {
    try {
      return await _dio.post('/api/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      return e.response;
    }
  }
}
