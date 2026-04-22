import 'package:flutter/material.dart';
import '../services/ticket_service.dart';
import '../models/ticket.dart';
import '../classes/authenticatie.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  bool _isChecked = false;
  bool _isLoading = false;
  final TicketService _ticketService = TicketService();

  // Controllers voor de velden
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _serialController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _causeController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pickupDateController = TextEditingController();

  final List<String> _frequencyOptions = ['Altijd', 'Vaak', 'Soms'];
  final List<String> _causeOptions = [
    'Software fout',
    'Defect onderdeel',
    'Geen oorzaak bekend',
    'Fout veroorzaakt door een reparatie'
  ];

  final List<String> _symptomOptions = [
    'Ac adaptor: Burnt Smell', 'Ac adaptor: Power: Intermittent Charge', 'Ac adaptor: Power: Output None',
    'Antenna: Coverage: None',
    'Barcode: Buttons not working', 'Barcode: No Device Installed',
    'Battery: Burnt Smell', 'Battery: Charge: Will Not Hold', 'Battery: LED: Blinking Red', 'Battery: Not Recognized',
    'Cabinet: Dropped', 'Cabinet: Hinge Damage', 'Cabinet: Port Cover Damage', 'Cabinet: Switch: Power Inoperable', 'Cabinet: Switch: Wireless Inoperable',
    'Circuit Board: Jack: DC - In Inoperable', 'Circuit Board: Jack: Headphone Failure', 'Circuit Board: Locks Up', 'Circuit Board: Overheats', 'Circuit Board: Port: DC - In Damage', 'Circuit Board: Port: Dock Inoperable', 'Circuit Board: Port: External Video Failure', 'Circuit Board: Port: Firewire Damage', 'Circuit Board: Port: HDMI Damage', 'Circuit Board: Port: Headphone Damage', 'Circuit Board: Port: LAN Damage', 'Circuit Board: Port: Serial Damage', 'Circuit Board: Port: Serial Failure', 'Circuit Board: Port: USB Damage', 'Circuit Board: Port: USB Failure', 'Circuit Board: Port: USB3 Damage', 'Circuit Board: Port: HDMI', 'Circuit Board: Port: USB3', 'Circuit Board: Power On Failure', 'Circuit Board: Power: Will Not Run off AC', 'Circuit Board: Power: Will Not Run off Batte * ', 'Circuit Board: Reboots', 'Circuit Board: Spillage/Corrosion ',
    'Fingerprint: Damage', 'Fingerprint: No Device Installed',
    'GPS: Damage', 'GPS: No Device Installed', 'GPS: No signal',
    'HDD: Hard Data: Bad Sectors', 'HDD: Hard Data: Locks up Accessing', 'HDD: Hard Data: No O/S Found', 'HDD: Hard Data: Will Not Image/Load', 'HDD: Hard Mechanical Noise', 'HDD: Hard Not Recognized',
    'Keyboard: Characters: Wrong', 'Keyboard: Damage', 'Keyboard: Not Recognized',
    'Lan – wired: Connection: None', 'Lan – wired: Connection: Slow Transfer Rate', 'Lan – wired: Not Recognized',
    'Lan Wireless: Connection: None', 'Lan Wireless: Connection: Slow Transfer Rate', 'Lan Wireless: Not Recognized',
    'LCD: Backlight Dim', 'LCD: Bar/Line: Horizontal', 'LCD: Bar/Line: Vertical', 'LCD: Cracked', 'LCD: Laminate', 'LCD: Pixels', 'LCD: Solid White/Gray Screen', 'LCD: Video - None',
    'Lind adaptor: Burnt Smell', 'Lind adaptor: Power: Intermittent Charge', 'Lind adaptor: Power: Output None',
    'Port rep: Jack: DC-In Inoperable', 'Port rep: Jack: Lan Failure', 'Port rep: Port: Dock Inoperable', 'Port rep: Port: External Video Failure ', 'Port rep: Port: HDMI', 'Port rep: Port: USB3',
    'Refurbished: Project Refur/Test/Image/Clean',
    'Smart card reader: Damage', 'Smart card reader: No Device Installed', 'Smart card reader: Unable to Read Smartcard',
    'Speaker: Speaker Sound Little', 'Speaker: Speaker Sound None',
    'SSD: SSD: Locks Up', 'SSD: SSD: No O/S Found', 'SSD: SSD: Not Recognized', 'SSD: SSD: Will Not Image/Load', 'SSD: SSD: Will Not Read/Write',
    'Touchpad: Buttons: Inoperable', 'Touchpad: Movement: Erratic Worn ', 'Touchpad: Movement: None',
    'Touchscreen: Cracked', 'Touchscreen: Movement: Erratic', 'Touchscreen: Peeling', 'Touchscreen: Scratched/Pitted'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? scannedCode = ModalRoute.of(context)?.settings.arguments as String?;
      if (scannedCode != null) {
        // Gebruik de nieuwe Regex methode om de ID eruit te halen
        _serialController.text = _cleanScannedCode(scannedCode) ?? scannedCode;
      }
    });
  }

  @override
  void dispose() {
    _modelController.dispose();
    _serialController.dispose();
    _descriptionController.dispose();
    _frequencyController.dispose();
    _causeController.dispose();
    _symptomsController.dispose();
    _fullNameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _pickupDateController.dispose();
    super.dispose();
  }

  // Verbeterde methode met REGEX om de ID uit de URL van de docent te halen
  String? _cleanScannedCode(String? code) {
    if (code == null || code.trim().isEmpty) return null;
    
    String cleanValue = code.trim();
    
    // Regex zoekt naar 'id=' gevolgd door alles tot aan de volgende '&' of het einde
    final RegExp regExp = RegExp(r'[?&]id=([^&]+)');
    final match = regExp.firstMatch(cleanValue);
    
    if (match != null && match.groupCount >= 1) {
      return match.group(1); // Geeft 'RMM-110028' terug
    }
    
    return cleanValue;
  }

  Future<void> _scanQRCode() async {
    final result = await Navigator.pushNamed(context, '/qr-scanner');
    if (result != null && mounted) {
      setState(() {
        // Maak de code schoon voordat deze in het tekstveld komt
        _serialController.text = _cleanScannedCode(result.toString()) ?? result.toString();
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now.add(const Duration(days: 2));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 2),
      helpText: 'Selecteer ophaaldatum',
      cancelText: 'Annuleren',
      confirmText: 'Kiezen',
    );

    if (picked != null) {
      setState(() {
        _pickupDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _handleFormSubmit() async {
    if (_modelController.text.trim().isEmpty || 
        _serialController.text.trim().isEmpty || 
        _descriptionController.text.trim().isEmpty ||
        _fullNameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _pickupDateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vul a.u.b. alle verplichte velden (*) in.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = await Authenticatie().getUserId();
      
      // Zorg dat we het 'schone' serienummer meesturen naar de backend (nog een extra check)
      final cleanSerial = _cleanScannedCode(_serialController.text.trim()) ?? _serialController.text.trim();

      final List<Map<String, dynamic>> answers = [
        {'question_id': 6, 'answer': _modelController.text.trim()},
        {'question_id': 7, 'answer': cleanSerial}, // HIER GAAT DE SCHONE ID NAAR DE DB
        {'question_id': 1, 'answer': _descriptionController.text.trim()},
        {'question_id': 2, 'answer': _frequencyController.text},
        {'question_id': 3, 'answer': _causeController.text},
        {'question_id': 4, 'answer': _symptomsController.text},
        {'question_id': 9, 'answer': _fullNameController.text.trim()},
        {'question_id': 10, 'answer': _companyController.text.trim()},
        {'question_id': 11, 'answer': _phoneController.text.trim()},
        {'question_id': 5, 'answer': _pickupDateController.text},
        {'question_id': 13, 'answer': _isChecked ? 'Geaccepteerd' : 'Niet geaccepteerd'},
      ];

      final Ticket ticket = Ticket(
        ticketTypeId: 1,
        assetId: cleanSerial,
        userId: userId,
        answers: answers,
      );

      final bool success = await _ticketService.createTicket(ticket);

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          _showSuccessDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Server fout (500). Ticket kon niet worden opgeslagen.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fout: $e')),
        );
      }
    }
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
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to overview
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Ticket aanmaken',
            style: TextStyle(
                color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(Icons.info_outline, 'Intro'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Vul het onderstaande formulier in om een RMA aan te vragen. Wij nemen zo snel mogelijk contact met u op om de ophaaldatum en -tijd te bevestigen.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 15),

            _buildSectionHeader(Icons.business_outlined, 'Apparaat Informatie'),
            const SizedBox(height: 15),
            _buildLabel('Model / Type *'),
            _buildTextField('Bijvoorbeeld: CF-XXXXXX of FZ-XXXXXX', _modelController),
            const SizedBox(height: 15),
            _buildLabel('Serienummer *'),
            _buildTextField(
              'Voer a.u.b. een serienummer in', 
              _serialController,
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
                onPressed: _scanQRCode,
              ),
            ),
            const SizedBox(height: 15),
            _buildLabel('Beschrijving van het probleem *'),
            _buildTextField('Beschrijf het probleem zo gedetailleerd mogelijk', _descriptionController, maxLines: 3),
            const SizedBox(height: 15),
            _buildLabel('Probleemfrequentie *'),
            _buildDropdownField(
              'Selecteer frequentie',
              _frequencyController,
              _frequencyOptions
            ),
            const SizedBox(height: 15),
            _buildLabel('Vermoedelijke oorzaak *'),
            _buildDropdownField(
              'Selecteer vermoedelijke oorzaak',
              _causeController,
              _causeOptions
            ),
            const SizedBox(height: 15),
            _buildLabel('Probleem verschijnselen *'),
            _buildDropdownField(
              'Selecteer verschijnsel',
              _symptomsController,
              _symptomOptions
            ),

            const SizedBox(height: 25),
            _buildSectionHeader(Icons.person_outline, 'Persoonlijke gegevens'),
            const SizedBox(height: 15),
            _buildLabel('Uw volledige naam *'),
            _buildTextField('Voer a.u.b. uw achternaam en voornaam in', _fullNameController),
            const SizedBox(height: 15),
            _buildLabel('Bedrijfsnaam'),
            _buildTextField('Voer a.u.b. een bedrijfsnaam in', _companyController),
            const SizedBox(height: 15),
            _buildLabel('Telefoonnummer *'),
            _buildTextField('Voer a.u.b. een telefoonnummer in', _phoneController),
            const SizedBox(height: 15),
            _buildLabel('Ophaaldatum *'),
            _buildTextField(
              'Selecteer een datum',
              _pickupDateController,
              readOnly: true,
              onTap: () => _selectDate(context),
              suffixIcon: const Icon(Icons.calendar_today, size: 20, color: Colors.blueGrey),
            ),

            const SizedBox(height: 20),

            CheckboxListTile(
              title: const Text(
                'Ik erken en ga ermee akkoord dat mijn apparaat tijdens het reparatieproces mogelijk wordt gewist of dat de gegevens ervan worden verwijderd. Ik begrijp dat deze maatregel noodzakelijk is om een effectieve reparatie te garanderen en mijn privacy en veiligheid te beschermen.\n\n'
                'Ik heb een back-up gemaakt van alle noodzakelijke gegevens en begrijp dat Dragon Media Group / Toughbookparts niet verantwoordelijk is voor enig gegevensverlies dat zich tijdens het reparatieproces kan voorden.',
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
                onPressed: (_isChecked && !_isLoading) ? _handleFormSubmit : null,
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
                        Text('Ticket Versturen ',
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

  Widget _buildTextField(String hint, TextEditingController controller, {int maxLines = 1, bool readOnly = false, VoidCallback? onTap, Widget? suffixIcon}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
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

  Widget _buildDropdownField(String hint, TextEditingController controller, List<String> options) {
    return DropdownButtonFormField<String>(
      value: options.contains(controller.text) ? controller.text : null,
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          controller.text = newValue ?? '';
        });
      },
      icon: const Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
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
