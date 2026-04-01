import 'package:flutter/material.dart';
import '../services/ticket_service.dart';
import '../core/constants/app_colors.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Succes'),
        content: const Text('Uw ticket is succesvol aangemaakt.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Sluit dialoog
              Navigator.pop(context); // Terug naar overzicht
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleFormSubmit(String? scannedCode) async {
    setState(() => _isLoading = true);

    final Map<String, dynamic> ticketData = {
      'ticket_type_id': 1,
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
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ticket aanmaken',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(Icons.business_outlined, 'BEDRIJF INFORMATIE'),
            const SizedBox(height: 15),
            _buildLabel('Bedrijfsnaam'),
            _buildTextField('Voer bedrijfsnaam in', controller: _companyController),
            const SizedBox(height: 15),
            _buildLabel('Telefoonnummer'),
            _buildTextField('Voer telefoonnummer in', controller: _phoneController),
            const SizedBox(height: 30),
            _buildSectionHeader(Icons.description_outlined, 'TICKET DETAILS'),
            const SizedBox(height: 15),
            _buildLabel('Model'),
            _buildTextField('Model van het apparaat', controller: _modelController),
            const SizedBox(height: 15),
            _buildLabel('Bericht'),
            _buildTextField('Beschrijf het probleem...', maxLines: 5, controller: _descriptionController),
            const SizedBox(height: 20),
            _buildUploadDocumentsButton(),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _handleFormSubmit(scannedCode),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Submit Ticket ', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                        Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                      ],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: AppColors.pureWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildUploadDocumentsButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.file_present_outlined, color: AppColors.textGray),
          SizedBox(width: 10),
          Text(
            'Upload Documents',
            style: TextStyle(color: AppColors.textGray, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
