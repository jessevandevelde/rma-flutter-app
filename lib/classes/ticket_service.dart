import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TicketService {
  late final Dio _dio;

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
  }

  Future<Response?> submitTicket(Map<String, dynamic> ticketData) async {
    try {
      final response = await _dio.post(
        '/api/tickets',
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
