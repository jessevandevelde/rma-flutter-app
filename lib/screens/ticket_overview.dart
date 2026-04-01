import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/support_request.dart';
import '../components/support_request_card.dart';
import '../components/custom_search_bar.dart';
import '../core/constants/app_colors.dart';

class TicketOverview extends StatefulWidget {
  const TicketOverview({super.key});

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
      iconColor: AppColors.primaryBlue,
    ),
    SupportRequest(
      title: 'Password Reset Issue',
      category: 'Password/Access',
      description: 'Cannot login to the portal.',
      date: 'Submitted: Oct 14, 2023',
      ticketId: '#USR-8955',
      status: 'OPEN',
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

  Future<void> _scanNewTicket() async {
    final String? barcodeValue = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerPage(),
      ),
    );

    if (!mounted) return;

    if (barcodeValue != null) {
      Navigator.pushNamed(
        context,
        '/create-ticket',
        arguments: barcodeValue,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        title: const Text(
          'Mijn Tickets',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Scan QR-Code'),
              onTap: () {
                Navigator.pop(context);
                _scanNewTicket();
              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Test QR Link (Dev)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/create-ticket',
                  arguments: 'https://dmg.support/qr?id=RMM-923478&login_token=gBX1dW1N',
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          CustomSearchBar(
            hintText: 'Zoek op titel of ID...',
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          Container(
            color: AppColors.pureWhite,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primaryBlue,
              tabs: const [Tab(text: 'Actief'), Tab(text: 'Afgerond')],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRequestList(),
                const Center(child: Text('Geen afgeronde tickets')),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanNewTicket,
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        label: const Text('Scan QR Code', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
            Text('Geen tickets gevonden', style: TextStyle(color: Colors.grey[600])),
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
              '/create-ticket'
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
      appBar: AppBar(
        title: const Text('Scan Ticket QR'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (_isScanCompleted) return;
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              setState(() => _isScanCompleted = true);
              debugPrint('Barcode gevonden! ${barcode.rawValue}');
              if (mounted) {
                Navigator.of(context).pop(barcode.rawValue);
              }
              break;
            }
          }
        },
      ),
    );
  }
}
