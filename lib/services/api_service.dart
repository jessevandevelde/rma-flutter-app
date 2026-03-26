import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/support_request.dart';
import 'package:flutter/material.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    const String mode = String.fromEnvironment('APP_MODE', defaultValue: 'dev');
    String baseUrl;
    
    if (mode == 'prod') {
      baseUrl = 'https://api.jouwproductieurl.com';
    } else {
      if (!kIsWeb && Platform.isAndroid) {
        baseUrl = 'http://10.0.2.2:8000';
      } else {
        baseUrl = 'http://127.0.0.1:8000';
      }
    }

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  Future<List<SupportRequest>> fetchRequests({String status = 'OPEN'}) async {
    try {
      final response = await _dio.get('/api/tickets', queryParameters: {'status': status});
      
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => _mapJsonToRequest(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('VERBINDINGSFOUT: ${e.message}');
      rethrow;
    }
  }

  Future<bool> createRequest(SupportRequest request) async {
    try {
      final response = await _dio.post(
        '/api/tickets',
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
      debugPrint('OPSLAAN MISLUKT: $e');
      return false;
    }
  }

  SupportRequest _mapJsonToRequest(Map<String, dynamic> json) {
    return SupportRequest(
      title: json['title'] ?? 'Geen titel',
      category: json['category'] ?? 'Algemeen',
      description: json['description'] ?? '',
      date: json['created_at'] ?? 'Vandaag',
      ticketId: json['ticketId'] ?? '#0000',
      status: json['status'] ?? 'OPEN',
      // UITLEG: Deze velden komen nu mee uit de 'ticket_data' tabel via de JOIN op de server
      productName: json['product_name'] ?? '',
      serialNumber: json['serial_number'] ?? '',
      icon: _getIcon(json['category']),
      iconColor: Colors.blue,
    );
  }

  IconData _getIcon(String? category) {
    if (category == 'Laptop') return Icons.laptop;
    if (category == 'Password/Access') return Icons.lock;
    return Icons.assignment;
  }
}
