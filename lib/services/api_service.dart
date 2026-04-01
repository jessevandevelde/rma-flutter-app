import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/support_request.dart';
import 'package:flutter/material.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
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

    // Interceptor om de 'auth_token' uit de SharedPreferences te halen en als 'user-token' te sturen.
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['user-token'] = token;
          // We behouden Authorization Bearer ook voor de zekerheid, 
          // tenzij je wilt dat deze strikt weg moet.
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));

    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  // Ophalen van tickets van de ingelogde gebruiker
  Future<List<SupportRequest>> fetchRequests({String status = 'OPEN', int? userId}) async {
    try {
      final queryParameters = {'status': status};
      if (userId != null) {
        queryParameters['user_id'] = userId.toString();
      }
      
      final response = await _dio.get('/api/ticket', queryParameters: queryParameters);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['tickets'] ?? [];
        return data.map((json) => _mapJsonToRequest(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('API Error: ${e.message}');
      rethrow;
    }
  }

  Future<SupportRequest?> fetchTicketById(int id) async {
    try {
      final response = await _dio.get('/api/ticket/$id');
      if (response.statusCode == 200) {
        return _mapJsonToRequest(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> createRequest(SupportRequest request) async {
    try {
      final response = await _dio.post(
        '/api/ticket',
        data: {
          'title': request.title,
          'category': request.category,
          'description': request.description,
          'ticketId': request.ticketId,
          'product_name': request.productName,
          'serial_number': request.serialNumber,
        },
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  SupportRequest _mapJsonToRequest(Map<String, dynamic> json) {
    final asset = json['asset'];
    final ticketType = json['ticket_type'];
    final statusObj = json['status']?['status'];

    return SupportRequest(
      title: asset?['description'] ?? 'Ticket #${json['id']}',
      category: ticketType?['friendly_name'] ?? 'Algemeen',
      description: asset?['description'] ?? '',
      date: json['created_at'] ?? 'Onbekend',
      ticketId: json['id']?.toString() ?? '#0000',
      status: statusObj?['name']?.toString().toUpperCase() ?? 'OPEN',
      productName: asset?['asset_type']?['name'] ?? '',
      serialNumber: asset?['serial_number'] ?? '',
      icon: _getIcon(ticketType?['name']),
      iconColor: Colors.blue,
    );
  }

  IconData _getIcon(String? category) {
    if (category == 'repair') return Icons.build;
    if (category == 'question') return Icons.help_outline;
    if (category == 'Laptop') return Icons.laptop;
    return Icons.assignment;
  }
}
