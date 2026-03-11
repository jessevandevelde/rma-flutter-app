import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: CreateTicketScreen()));

class CreateTicketScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool _isChecked = false;
    dynamic setState;

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
            _buildSectionHeader(Icons.business_outlined, ''),
            SizedBox(height: 15),
            _buildLabel('Intro Text'),
            _buildTextField(''),
            SizedBox(height: 15),
            _buildLabel('Bekijk het reparatieproces'),
            _buildTextField(''),
            SizedBox(height: 15),
            _buildLabel('Model / Type'),
            _buildTextField('For example: CF-XXXXXX or FZ-XXXXXX'),
            SizedBox(height: 15),
            _buildLabel('Serienummer'),
            _buildTextField('Please enter a serial number'),
            SizedBox(height: 15),
            _buildLabel('Beschrijving van het probleem'),
            _buildTextField('Beschrijf het probleem zo gedetailleerd mogelijk.'),
            SizedBox(height: 15),
            _buildLabel('Probleemfrequentie'),
            _buildTextField(''),
            SizedBox(height: 15),
            _buildLabel('Vermoedelijke oorzaak'),
            _buildTextField(''),
            SizedBox(height: 15),
            _buildLabel('Symptonen'),
            _buildTextField(''),
            SizedBox(height: 15),
            _buildLabel('Persoonlijke gegevens'),
            _buildTextField(''),
            SizedBox(height: 15),
            _buildLabel('Uw bedrijfsnaam'),
            _buildTextField('Voer een bedrijfsnaam in'),
            SizedBox(height: 15),
            _buildLabel('Jouw telefoonnummer'),
            _buildTextField('Voer een telefoonnummer in'),
            SizedBox(height: 15),
            _buildLabel('Ophaaldatum'),
            _buildTextField(''),

            

            CheckboxListTile(
              title: Text(
                "Ik erken en ga ermee akkoord dat mijn apparaat tijdens het reparatieproces mogelijk wordt gewist of dat de gegevens ervan worden verwijderd. Ik begrijp dat deze maatregel noodzakelijk is om een effectieve reparatie te garanderen en mijn privacy en veiligheid te beschermen.\n\n"
                    "Ik heb een back-up gemaakt van alle noodzakelijke gegevens en begrijp dat Dragon Media Group / Toughbookparts niet verantwoordelijk is voor enig gegevensverlies dat zich tijdens het reparatieproces kan voordoen.",
                style: TextStyle(fontSize: 14),
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


            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF007AFF), // Blauwe kleur
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
  }