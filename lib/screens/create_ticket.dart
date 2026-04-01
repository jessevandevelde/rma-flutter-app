import 'package:flutter/material.dart';
import '../services/ticket_service.dart';
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
  bool _isChecked = false;
  bool _isLoading = false;
  final TicketService _ticketService = TicketService();

  // Controllers voor alle velden
  final TextEditingController _introController = TextEditingController();
  final TextEditingController _repairProcessController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _serialController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _causeController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _personalDataController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pickupDateController = TextEditingController();

  @override
  void dispose() {
    _introController.dispose();
    _repairProcessController.dispose();
    _modelController.dispose();
    _serialController.dispose();
    _descriptionController.dispose();
    _frequencyController.dispose();
    _causeController.dispose();
    _symptomsController.dispose();
    _personalDataController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _pickupDateController.dispose();
    super.dispose();
  }

  Future<void> _handleFormSubmit(String? scannedCode) async {
    setState(() => _isLoading = true);

    final Map<String, dynamic> ticketData = {
      'ticket_type_id': 1, // Added mandatory field. Adjust this ID based on your backend.
      'scannedCode': scannedCode,
      'intro': _introController.text,
      'repair_process': _repairProcessController.text,
      'model': _modelController.text,
      'serial': _serialController.text,
      'description': _descriptionController.text,
      'frequency': _frequencyController.text,
      'cause': _causeController.text,
      'symptoms': _symptomsController.text,
      'personal_data': _personalDataController.text,
      'company': _companyController.text,
      'phone': _phoneController.text,
      'pickup_date': _pickupDateController.text,
    };

    final bool success = await _ticketService.createTicket(ticketData);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Er is iets fout gegaan bij het aanmaken van het ticket.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? scannedCode = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Ticket aanmaken',
            style: TextStyle(
                color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (scannedCode != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.qr_code, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('Gescannde code: $scannedCode',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            _buildSectionHeader(Icons.business_outlined, 'Informatie'),
            const SizedBox(height: 15),
            _buildLabel('Intro Text'),
            _buildTextField('', _introController),
            const SizedBox(height: 15),
            _buildLabel('Bekijk het reparatieproces'),
            _buildTextField('', _repairProcessController),
            const SizedBox(height: 15),
            _buildLabel('Model / Type'),
            _buildTextField('For example: CF-XXXXXX or FZ-XXXXXX', _modelController),
            const SizedBox(height: 15),
            _buildLabel('Serienummer'),
            _buildTextField('Please enter a serial number', _serialController),
            const SizedBox(height: 15),
            _buildLabel('Beschrijving van het probleem'),
            _buildTextField('Beschrijf het probleem zo gedetailleerd mogelijk.', _descriptionController, maxLines: 3),
            const SizedBox(height: 15),
            _buildLabel('Probleemfrequentie'),
            _buildTextField('', _frequencyController),
            const SizedBox(height: 15),
            _buildLabel('Vermoedelijke oorzaak'),
            _buildTextField('', _causeController),
            const SizedBox(height: 15),
            _buildLabel('Symptonen'),
            _buildTextField('', _symptomsController),
            const SizedBox(height: 15),
            _buildLabel('Persoonlijke gegevens'),
            _buildTextField('', _personalDataController),
            const SizedBox(height: 15),
            _buildLabel('Uw bedrijfsnaam'),
            _buildTextField('Voer een bedrijfsnaam in', _companyController),
            const SizedBox(height: 15),
            _buildLabel('Jouw telefoonnummer'),
            _buildTextField('Voer een telefoonnummer in', _phoneController),
            const SizedBox(height: 15),
            _buildLabel('Ophaaldatum'),
            _buildTextField('', _pickupDateController),

            const SizedBox(height: 10),

            CheckboxListTile(
              title: const Text(
                'Ik erken en ga ermee akkoord dat mijn apparaat tijdens het reparatieproces mogelijk wordt gewist of dat de gegevens ervan worden verwijderd. Ik begrijp dat deze maatregel noodzakelijk is om een effectieve reparatie te garanderen en mijn privacy en veiligheid te beschermen.\n\n'
                'Ik heb een back-up gemaakt van alle noodzakelijke gegevens en begrijp dat Dragon Media Group / Toughbookparts niet verantwoordelijk is voor enig gegevensverlies dat zich tijdens het reparatieproces kan voordoen.',
                style: TextStyle(fontSize: 13),
              ),
              value: _isChecked,
              onChanged: (bool? value) {
                setState(() {
                  _isChecked = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (_isChecked && !_isLoading) ? () => _handleFormSubmit(scannedCode) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isChecked ? const Color(0xFF007AFF) : Colors.grey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Submit Ticket ',
                            style: TextStyle(fontSize: 18, color: Colors.white)),
                        Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('Succes'),
            ],
          ),
          content: const Text('Uw ticket is succesvol aangemaakt!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey)),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: TextStyle(
              fontWeight: FontWeight.w600, color: Colors.blueGrey[800])),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue[200]!),
        ),
      ),
    );
  }
}
