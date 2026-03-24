import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../models/support_request.dart';
import '../components/custom_button.dart';
import '../components/custom_text_field.dart';
import '../components/custom_label.dart';

class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({super.key});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'Laptop';
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _categories = ['Laptop', 'Password/Access', 'Keyboard', 'Software', 'Other'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      IconData icon;
      Color iconColor;
      
      switch (_selectedCategory) {
        case 'Laptop':
          icon = Icons.laptop_chromebook;
          iconColor = Colors.blue;
          break;
        case 'Password/Access':
          icon = Icons.vpn_key_outlined;
          iconColor = Colors.orange;
          break;
        case 'Keyboard':
          icon = Icons.keyboard_alt_outlined;
          iconColor = Colors.orange;
          break;
        default:
          icon = Icons.assignment_outlined;
          iconColor = Colors.green;
      }

      final newRequest = SupportRequest(
        title: _titleController.text,
        category: _selectedCategory,
        description: _descriptionController.text,
        date: 'Submitted: ${DateFormat('MMM d, yyyy').format(DateTime.now())}',
        ticketId: '#USR-${Random().nextInt(9000) + 1000}',
        status: 'OPEN',
        icon: icon,
        iconColor: iconColor,
      );

      Navigator.of(context).pop(newRequest);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request submitted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'New Support Request',
          style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What can we help you with?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const CustomLabel(text: 'Category'),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              const CustomLabel(text: 'Title'),
              CustomTextField(
                controller: _titleController,
                hint: 'Short summary of the issue',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a title';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const CustomLabel(text: 'Description'),
              CustomTextField(
                controller: _descriptionController,
                maxLines: 5,
                hint: 'Provide as much detail as possible',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a description';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Submit Request',
                onPressed: _submitRequest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
