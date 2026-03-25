import 'dart:convert';
import 'package:http/http.dart' as http;

class TicketService {
  // 10.0.2.2 is het adres om de localhost van je computer te bereiken vanuit de Android Emulator.
  // Gebruik 'localhost' als je de iOS simulator gebruikt.
  static const String _baseUrl = 'http://10.0.2.2:8000/api';

  Future<bool> createTicket(Map<String, dynamic> ticketData) async {
    try {
      // We proberen /api/tickets aan te roepen (meest gebruikelijk in Laravel)
      final response = await http.post(
        Uri.parse('$_baseUrl/ticket'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // Dit zorgt ervoor dat Laravel JSON terugstuurt bij errors
        },
        body: jsonEncode(ticketData),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        // Als je hier een 405 error krijgt, check dan je routes/api.php op de backend.
        return false;
      }
    } catch (e) {
      print('Fout bij aanmaken ticket: $e');
      return false;
    }
  }
}
