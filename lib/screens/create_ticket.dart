import 'package:flutter/material.dart';
import '../components/section_header.dart';
import '../components/custom_label.dart';
import '../components/custom_text_field.dart';

class CreateTicketScreen extends StatelessWidget {
  const CreateTicketScreen({super.key});

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
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- COMPANY INFORMATION ---
            const SectionHeader(
                icon: Icons.business_outlined, title: 'Bedrijf informatie'),
            const SizedBox(height: 15),
            const CustomLabel(text: 'Bedrijf naam'),
            const CustomTextField(hint: 'Bedrijfsnaam'),
            const SizedBox(height: 15),
            const CustomLabel(text: 'Contact Persoon'),
            const CustomTextField(hint: 'Volledige naam'),

            const SizedBox(height: 30),

            // --- TICKET DETAILS ---
            const SectionHeader(
                icon: Icons.description_outlined, title: 'TICKET DETAILS'),
            const SizedBox(height: 15),
            const CustomLabel(text: 'Probleem Title'),
            const CustomTextField(hint: 'Korte samenvatting van het probleem'),
            const SizedBox(height: 15),
            const CustomLabel(text: 'Probleem omschrijving'),
            const CustomTextField(
                hint: 'Beschrijf het probleem in detail....', maxLines: 5),

            const SizedBox(height: 20),

            // --- Button voor upload ---
            _buildUploadDocumentsButton(),

            const SizedBox(height: 40),

            // --- Submit button ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: const Row(
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

  // "Upload Documents" knop (kan later ook een component worden)
  Widget _buildUploadDocumentsButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.file_present_outlined, color: Colors.blueGrey),
          SizedBox(width: 10),
          Text('Upload Documents',
              style: TextStyle(
                  color: Color(0xFF455A64), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
