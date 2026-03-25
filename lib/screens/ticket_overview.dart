import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/support_request.dart';
import '../components/support_request_card.dart';
import '../components/custom_search_bar.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MaterialApp(
    home: TicketOverview(),
  ));
}

class TicketOverview extends StatefulWidget {
  const TicketOverview({super.key});

  // Functie om de externe link te openen
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Kon $url niet openen');
    }
  }

  @override
  State<TicketOverview> createState() => _TicketOverviewState();
}

class _TicketOverviewState extends State<TicketOverview> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  final List<SupportRequest> _requests = [
    SupportRequest(
      title: 'Broken Laptop Screen',
      category: 'Laptop',
      description: 'Screen is cracked after a fall.',
      date: 'Submitted: Oct 12, 2023',
      ticketId: '#USR-8942',
      status: 'NEED INFO',
      icon: Icons.laptop_chromebook,
      iconColor: Colors.blue,
    ),
    SupportRequest(
      title: 'Password Reset Issue',
      category: 'Password/Access',
      description: 'Cannot login to the portal.',
      date: 'Submitted: Oct 14, 2023',
      ticketId: '#USR-8955',
      status: 'NEED INFO',
      icon: Icons.vpn_key_outlined,
      iconColor: Colors.orange,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<SupportRequest> get _filteredRequests {
    if (_searchQuery.isEmpty) return _requests;
    return _requests.where((request) {
      final searchLower = _searchQuery.toLowerCase();
      return request.title.toLowerCase().contains(searchLower) ||
          request.ticketId.toLowerCase().contains(searchLower) ||
          request.category.toLowerCase().contains(searchLower);
    }).toList();
  }

  void _scanNewTicket() async {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.red),
            tooltip: 'Dev: Open Chat',
            onPressed: () => Navigator.pushNamed(context, '/support-chat', arguments: '#DEV-1234'),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          CustomSearchBar(
            hintText: 'Search by title, ID or category',
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue[700],
            indicatorColor: Colors.blue[700],
            tabs: const [Tab(text: 'Active'), Tab(text: 'Past')],
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRequestList(),
                const Center(child: Text('Past Requests')),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanNewTicket,
        backgroundColor: const Color(0xFF2962FF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Request', style: TextStyle(color: Colors.white)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildRequestList() {
    final filtered = _filteredRequests;
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No requests found', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return SupportRequestCard(
          request: filtered[index],
          onViewDetails: () {
            Navigator.pushNamed(
              context,
              '/support-chat',
              arguments: filtered[index].ticketId
            );
          },
        );
      },
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
              setState(() => _isScanCompleted = true);
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
