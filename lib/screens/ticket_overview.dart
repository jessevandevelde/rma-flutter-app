import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/support_request.dart';
import '../components/support_request_card.dart';
import '../components/custom_search_bar.dart';
import '../services/api_service.dart';

class TicketOverview extends StatefulWidget {
  const TicketOverview({super.key});

  @override
  State<TicketOverview> createState() => _TicketOverviewState();
}

class _TicketOverviewState extends State<TicketOverview> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  
  List<SupportRequest> _activeRequests = [];
  List<SupportRequest> _pastRequests = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadTickets();
      }
    });

    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    try {
      final String status = _tabController.index == 0 ? 'OPEN' : 'CLOSED';
      final tickets = await _apiService.fetchRequests(status: status);
      
      setState(() {
        if (_tabController.index == 0) {
          _activeRequests = tickets;
        } else {
          _pastRequests = tickets;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fout bij het laden van tickets')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<SupportRequest> _getFilteredList(List<SupportRequest> list) {
    if (_searchQuery.isEmpty) return list;
    return list.where((request) {
      final searchLower = _searchQuery.toLowerCase();
      return request.title.toLowerCase().contains(searchLower) ||
          request.ticketId.toLowerCase().contains(searchLower);
    }).toList();
  }

  // UITLEG: Ik heb deze functie aangepast zodat hij direct naar het formulier gaat
  // in plaats van eerst de camera te openen voor een scan.
  void _createNewRequest() async {
    final result = await Navigator.pushNamed(context, '/create-ticket');
    
    // Als er een nieuw ticket is aangemaakt, verversen we de lijst
    if (result == true) {
      _loadTickets();
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
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadTickets,
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
            hintText: 'Search by title or ID',
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF1976D2),
            indicatorColor: const Color(0xFF1976D2),
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Past'),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRequestList(_getFilteredList(_activeRequests)),
                    _buildRequestList(_getFilteredList(_pastRequests)),
                  ],
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewRequest, // Nu direct naar het formulier
        backgroundColor: const Color(0xFF2962FF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Request', style: TextStyle(color: Colors.white)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildRequestList(List<SupportRequest> list) {
    if (list.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                const Icon(Icons.search_off, size: 64, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 16),
                const Text('No requests found', style: TextStyle(color: Color(0xFF757575))),
              ],
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTickets,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return SupportRequestCard(
            request: list[index],
            onViewDetails: () {
              Navigator.pushNamed(context, '/support-chat', arguments: list[index].ticketId);
            },
          );
        },
      ),
    );
  }
}

// Barcode scanner pagina blijft bestaan voor als je hem later nodig hebt via een andere knop
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
