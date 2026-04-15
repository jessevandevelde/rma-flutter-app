import 'package:flutter/material.dart';

class SupportRequest {
  final String title;
  final String category;
  final String description;
  final String date;
  final String ticketId;
  final String status;
  final IconData icon;
  final Color iconColor;
  final String priority;
  final Color priorityColor;
  final Color statusColor;
  final String productName;
  final String serialNumber;

  SupportRequest({
    required this.title,
    required this.category,
    required this.description,
    required this.date,
    required this.ticketId,
    required this.status,
    required this.icon,
    required this.iconColor,
    this.priority = 'LOW',
    this.priorityColor = Colors.grey,
    this.statusColor = Colors.blue,
    this.productName = '',
    this.serialNumber = '',
  });
}
