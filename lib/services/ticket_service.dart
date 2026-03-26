import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class TicketService {
  late final Dio _dio;

  TicketService() {
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
  }

  Future<bool> createTicket(Map<String, dynamic> ticketData) async {
    try {
      final response = await _dio.post(
        '/api/ticket',
        data: ticketData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      debugPrint('Fout bij aanmaken ticket: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout) {
        debugPrint('Timeout: Is de server op wel bereikbaar?');
      }
      return false;
    }
  }
}
