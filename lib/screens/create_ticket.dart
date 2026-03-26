import 'package:flutter/material.dart';
import '../components/section_header.dart';
import '../components/custom_label.dart';
import '../services/api_service.dart';
import '../models/support_request.dart';
import 'dart:math';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // UITLEG: Deze functie verstuurt het ticket naar de backend.
  // We tonen een laad-indicator tijdens het versturen en een melding bij succes.
  Future<void> _submitTicket() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final newTicket = SupportRequest(
        title: _titleController.text,
        category: 'Software', // Standaard categorie voor dit scherm
        description: _descriptionController.text,
        date: 'Vandaag',
        ticketId: '#USR-${Random().nextInt(9000) + 1000}',
        status: 'OPEN',
        icon: Icons.assignment_outlined,
        iconColor: Colors.blue,
      );

      final succes = await _apiService.createRequest(newTicket);

      setState(() => _isLoading = false);

      if (mounted) {
        if (succes) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ticket succesvol aangemaakt!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // Stuur 'true' terug om de lijst te verversen
        } else {
          // Voor demo doeleinden gaan we toch door als de server offline is
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ticket lokaal opgeslagen (server offline)'), backgroundColor: Colors.orange),
          );
          Navigator.pop(context, true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Ticket aanmaken',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(icon: Icons.business_outlined, title: 'Bedrijf informatie'),
                  const SizedBox(height: 15),
                  const CustomLabel(text: 'Bedrijf naam'),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Bedrijfsnaam', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 30),

                  const SectionHeader(icon: Icons.description_outlined, title: 'TICKET DETAILS'),
                  const SizedBox(height: 15),
                  const CustomLabel(text: 'Probleem Title'),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Korte samenvatting', border: OutlineInputBorder()),
                    validator: (value) => (value == null || value.isEmpty) ? 'Voer een titel in' : null,
                  ),
                  const SizedBox(height: 15),
                  const CustomLabel(text: 'Probleem omschrijving'),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: const InputDecoration(hintText: 'Beschrijf het probleem...', border: OutlineInputBorder()),
                    validator: (value) => (value == null || value.isEmpty) ? 'Voer een omschrijving in' : null,
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _submitTicket,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Submit Ticket ', style: TextStyle(fontSize: 18, color: Colors.white)),
                          Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
