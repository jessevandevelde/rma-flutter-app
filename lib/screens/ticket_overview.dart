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
          onPressed: () async {
            // 1. Open de scanner en wacht op het resultaat
            final String? barcodeValue = await Navigator.of(context).push<String>(
              MaterialPageRoute(
                builder: (context) => const BarcodeScannerPage(),
              ),
            );

            // 2. Als we een code hebben, ga naar create-ticket
            if (barcodeValue != null && context.mounted) {
              Navigator.pushNamed(
                context,
                '/create-ticket',
                arguments: barcodeValue,
              );
            }
          },
          child: const Text('Bevestig Ticket'),
        ),
      ),
    );
  }
}

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  // Deze variabele zorgt ervoor dat we maar één keer reageren op een scan
  bool _isScanCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Ticket')),
      body: MobileScanner(
        onDetect: (capture) {
          if (_isScanCompleted) return;

          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              setState(() {
                _isScanCompleted = true;
              });

              debugPrint('Barcode gevonden! ${barcode.rawValue}');

              // Sluit de scanner en geef de waarde terug
              Navigator.of(context).pop(barcode.rawValue);
              break;
            }
          }
        },
      ),
    );
  }
}
