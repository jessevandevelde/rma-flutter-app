import 'package:flutter/material.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    // Get the scanned code from the arguments
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

            // --- COMPANY INFORMATION ---
            _buildSectionHeader(Icons.business_outlined, 'Informatie'),
            const SizedBox(height: 15),
            _buildLabel('Intro Text'),
            _buildTextField(''),
            const SizedBox(height: 15),
            _buildLabel('Bekijk het reparatieproces'),
            _buildTextField(''),
            const SizedBox(height: 15),
            _buildLabel('Model / Type'),
            _buildTextField('For example: CF-XXXXXX or FZ-XXXXXX'),
            const SizedBox(height: 15),
            _buildLabel('Serienummer'),
            _buildTextField('Please enter a serial number'),
            const SizedBox(height: 15),
            _buildLabel('Beschrijving van het probleem'),
            _buildTextField('Beschrijf het probleem zo gedetailleerd mogelijk.',
                maxLines: 3),
            const SizedBox(height: 15),
            _buildLabel('Probleemfrequentie'),
            _buildTextField(''),
            const SizedBox(height: 15),
            _buildLabel('Vermoedelijke oorzaak'),
            _buildTextField(''),
            const SizedBox(height: 15),
            _buildLabel('Symptonen'),
            _buildTextField(''),
            const SizedBox(height: 15),
            _buildLabel('Persoonlijke gegevens'),
            _buildTextField(''),
            const SizedBox(height: 15),
            _buildLabel('Uw bedrijfsnaam'),
            _buildTextField('Voer een bedrijfsnaam in'),
            const SizedBox(height: 15),
            _buildLabel('Jouw telefoonnummer'),
            _buildTextField('Voer een telefoonnummer in'),
            const SizedBox(height: 15),
            _buildLabel('Ophaaldatum'),
            _buildTextField(''),

            const SizedBox(height: 10),

            // De Checkbox direct in de lijst
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
                onPressed: _isChecked ? () {
                  // Submit logica hier
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isChecked ? const Color(0xFF007AFF) : Colors.grey,
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

  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return TextField(
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
