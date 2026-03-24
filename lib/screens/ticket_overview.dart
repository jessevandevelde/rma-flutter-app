import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/support_request.dart';

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

  void _scanNewTicket() async {
    final String? barcodeValue = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerPage(),
      ),
    );

    if (barcodeValue != null && mounted) {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Support Requests',
          style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold),
        ),
        actions: [
          // DEV BUTTON: Snel naar de chat voor testing
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.red),
            tooltip: 'Dev: Open Chat',
            onPressed: () {
              Navigator.pushNamed(
                context, 
                '/support-chat', 
                arguments: '#DEV-1234'
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search by title, ID or category',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final request = _requests[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: ListTile(
            leading: Icon(request.icon, color: request.iconColor),
            title: Text(request.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Ticket ID: ${request.ticketId}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(
                context, 
                '/support-chat', 
                arguments: request.ticketId
              );
            },
          ),
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
              Navigator.of(context).pop(barcode.rawValue);
              break;
            }
          }
        },
      ),
    );
  }
}
