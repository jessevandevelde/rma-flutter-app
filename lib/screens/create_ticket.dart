import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: CreateTicketScreen()));

class CreateTicketScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Icon(Icons.arrow_back_ios, color: Colors.black87),
        title: Text('Ticket aanmaken', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- COMPANY INFORMATION ---
            _buildSectionHeader(Icons.business_outlined, 'Bedrijf informatie'),
            SizedBox(height: 15),
            _buildLabel('Bedrijf naam'),
            _buildTextField('Bedrijfsnaam'),
            SizedBox(height: 15),
            _buildLabel('Contact Persoon'),
            _buildTextField('Volledige naam'),

            SizedBox(height: 30),

            // --- TICKET DETAILS ---
            _buildSectionHeader(Icons.description_outlined, 'TICKET DETAILS'),
            SizedBox(height: 15),
            _buildLabel('Probleem Title'),
            _buildTextField('Korte samenvatting van het probleem'),
            SizedBox(height: 15),
            _buildLabel('Probleem omschrijving'),
            _buildTextField('Beschrijf het probleem in detail....', maxLines: 5),

            SizedBox(height: 20),

            // --- Image picker ---
            Row(
              children: [
                // --- Waar de images komen ---
                // _buildAddPhotoButton(),
                // SizedBox(width: 10),
                // _buildImagePreview(''),
                // SizedBox(width: 10),
                // _buildImagePreview(''),
              ],
            ),

            SizedBox(height: 20),

            // --- Button voor upload ---
            _buildUploadDocumentsButton(),

            SizedBox(height: 40),

            // --- Submit button ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF007AFF), // Blauwe kleur van foto
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Row(
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
    );
  }

  // Helper om sectie titels te bouwen
  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),
        SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
      ],
    );
  }

  // Helper voor labels boven de velden
  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey[800])),
    );
  }

  // Helper voor text input velden
  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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

  // "Upload Documents" knop
  Widget _buildUploadDocumentsButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.file_present_outlined, color: Colors.blueGrey),
          SizedBox(width: 10),
          Text('Upload Documents', style: TextStyle(color: Colors.blueGrey[700], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}