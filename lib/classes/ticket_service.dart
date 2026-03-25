import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TicketService {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  TicketService() {
    // 10.0.2.2 is the address to access localhost from the Android Emulator
    const String baseUrl = 'http://10.0.2.2:8000';

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
  }

  Future<Response?> submitTicket(Map<String, dynamic> ticketData) async {
    try {
      final response = await _dio.post(
        'api/ticket',
        data: ticketData,
      );
      return response;
    } on DioException catch (e) {
      debugPrint('Ticket submit error: ${e.message}');
      if (e.response != null) return e.response;
      rethrow;
    }
  }
}
