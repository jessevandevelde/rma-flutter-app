import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class Authenticatie {
  late final Dio _dio;

  Authenticatie() {
    String baseUrl = 'http://127.0.0.1:8000';
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

      if (response.statusCode == 200) {
        final data = response.data;
        final userId = data['user']?['id'];
        
        if (userId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', userId);
        }
      }
      return response;
    } on DioException catch (e) {
      return e.response;
    }
  }

  // UITLEG: Deze methode ontbrak en veroorzaakte de build error.
  // Het verstuurt een verzoek naar de backend om een reset-link te genereren.
  Future<Response?> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '/api/auth/forgot-password',
        data: {
          'email': email,
        },
      );
      return response;
    } on DioException catch (e) {
      return e.response;
    }
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }
}
