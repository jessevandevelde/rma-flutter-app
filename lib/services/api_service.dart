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

  // Haal dashboard statistieken op
  Future<Map<String, dynamic>> fetchDashboardData() async {
    try {
      final response = await _dio.get('/api/dashboard');
      if (response.statusCode == 200) {
        return response.data;
      }
      return {'open': 0, 'in_progress': 0, 'resolved': 0};
    } catch (e) {
      debugPrint('Dashboard API Error: $e');
      return {'open': 0, 'in_progress': 0, 'resolved': 0};
    }
  }

  // Haal alle tickets op
  Future<List<SupportRequest>> fetchAllTickets() async {
    try {
      final response = await _dio.get('/api/ticket');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['tickets'] ?? response.data;
        return data.map((json) => _mapJsonToRequest(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Tickets API Error: $e');
      return [];
    }
  }

  SupportRequest _mapJsonToRequest(Map<String, dynamic> json) {
    final asset = json['asset'];
    final ticketType = json['ticket_type'];
    final statusObj = json['status'];
    
    // Priority mapping
    final priorityStr = (json['priority'] ?? 'LOW').toString().toUpperCase();
    Color pColor = Colors.grey;
    if (priorityStr.contains('HIGH')) {
      pColor = Colors.red;
    } else if (priorityStr.contains('MEDIUM')) {
      pColor = Colors.orange;
    }

    // Status mapping
    final statusName = (statusObj?['name'] ?? 'OPEN').toString().toUpperCase();
    Color sColor = const Color(0xFF3B82F6); // Default Blue for OPEN
    if (statusName == 'IN PROGRESS') {
      sColor = Colors.orange;
    } else if (statusName == 'RESOLVED' || statusName == 'CLOSED') {
      sColor = const Color(0xFF10B981);
    }

    return SupportRequest(
      title: json['subject'] ?? asset?['description'] ?? 'Ticket #${json['id']}',
      category: ticketType?['friendly_name'] ?? 'Algemeen',
      description: json['description'] ?? asset?['description'] ?? '',
      date: _formatDate(json['created_at']),
      ticketId: 'TKT-${json['id']}',
      status: statusName,
      statusColor: sColor,
      priority: priorityStr,
      priorityColor: pColor,
      icon: Icons.assignment,
      iconColor: Colors.blue,
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'unknown';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      return '${difference.inDays}d ago';
    } catch (e) {
      return dateStr;
    }
  }
}
