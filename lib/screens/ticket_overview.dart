import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class TicketOverview extends StatelessWidget {
  const TicketOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ticket Overzicht')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 1. Navigate to the Scanner Page
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const BarcodeScannerPage(),
              ),
            );
          },
          child: const Text('Bevestig Ticket'),
        ),
      ),
    );
  }
}

class BarcodeScannerPage extends StatelessWidget {
  const BarcodeScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Ticket')),
      // 2. MobileScanner fills the screen
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            debugPrint('Barcode found! ${barcode.rawValue}');

            // 3. Close the scanner and return the value
            Navigator.of(context).pop(barcode.rawValue);
            break;
          }
        },
      ),
    );
  }
}