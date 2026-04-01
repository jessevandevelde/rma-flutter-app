import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:rma_app/classes/authenticatie.dart';
import '../models/support_request.dart';
import '../components/support_request_card.dart';
import '../components/custom_search_bar.dart';
import '../services/api_service.dart';
import '../core/constants/app_colors.dart';

class TicketOverview extends StatefulWidget {
  const TicketOverview({super.key});

  @override
  State<TicketOverview> createState() => _TicketOverviewState();
}

class _TicketOverviewState extends State<TicketOverview> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Authenticatie _authService = Authenticatie();
  final ApiService _apiService = ApiService();

  List<SupportRequest> _activeRequests = [];
  List<SupportRequest> _pastRequests = [];
  bool _isLoading = true;
  String _searchQuery = '';
  SupportRequest? _searchedTicketById;

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

  // UITLEG: We halen nu de tickets op van de ingelogde gebruiker
  Future<void> _loadTickets() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final int? userId = await _authService.getUserId();
      final String status = _tabController.index == 0 ? 'OPEN' : 'CLOSED';

      // We geven het userId mee aan de API call
      final tickets = await _apiService.fetchRequests(status: status, userId: userId);

      if (mounted) {
        setState(() {
          if (_tabController.index == 0) {
            _activeRequests = tickets;
          } else {
            _pastRequests = tickets;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fout bij het laden van tickets')),
        );
      }
    }
  }

  Future<void> _searchTicketById(String value) async {
    if (value.isEmpty) {
      setState(() => _searchedTicketById = null);
      return;
    }

    final int? id = int.tryParse(value);
    if (id != null) {
      final ticket = await _apiService.fetchTicketById(id);
      setState(() {
        _searchedTicketById = ticket;
      });
    } else {
      setState(() => _searchedTicketById = null);
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

  void _createNewRequest() async {
    final result = await Navigator.pushNamed(context, '/create-ticket');
    if (result == true) {
      _loadTickets();
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('My Tickets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadTickets,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          CustomSearchBar(
            hintText: 'Search tickets...',
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _searchTicketById(value);
            },
          ),
          if (_searchedTicketById != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resultaat op ID:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SupportRequestCard(
                    request: _searchedTicketById!,
                    onViewDetails: () {
                      Navigator.pushNamed(context, '/support-chat', arguments: _searchedTicketById!.ticketId);
                    },
                  ),
                  const Divider(thickness: 2),
                ],
              ),
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
        onPressed: _createNewRequest,
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
          const Center(
            child: Column(
              children: [
                Icon(Icons.search_off, size: 64, color: Color(0xFFE0E0E0)),
                SizedBox(height: 16),
                Text('No tickets found for you', style: TextStyle(color: Color(0xFF757575))),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return SupportRequestCard(
          request: list[index],
          onViewDetails: () {
            Navigator.pushNamed(
              context,
              '/support-chat',
              arguments: list[index].ticketId,
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
