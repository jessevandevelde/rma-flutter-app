import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MaterialApp(
    home: TicketOverview(),
  ));
}

class TicketOverview extends StatelessWidget {
  const TicketOverview({super.key});

  // Functie om de externe link te openen
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Kon $url niet openen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ticket Overzicht')),
      body: Center(
        // We gebruiken een Column om meerdere widgets onder elkaar te plaatsen
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // EERSTE KNOP: Scanner openen
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () async {
                final String? barcodeValue = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (context) => const BarcodeScannerPage(),
                  ),
                );

                if (barcodeValue != null && context.mounted) {
                  Navigator.pushNamed(
                    context,
                    '/create-ticket',
                    arguments: barcodeValue,
                  );
                }
              },
              label: const Text('Scan QR-Code'),
            ),

            // Ruimte tussen de twee knoppen
            const SizedBox(height: 20),

            // TWEEDE KNOP
            ElevatedButton.icon(
              icon: const Icon(Icons.bug_report),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/create-ticket',
                  arguments: 'https://dmg.support/qr?id=RMM-923478&login_token=gBX1dW1N',
                );
              },
              label: const Text('Test QR Link'),
            ),
          ],
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
              Navigator.of(context).pop(barcode.rawValue);
              break;
            }
          }
        },
      ),
    );
  }
}
