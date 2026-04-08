import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class TicketOverview extends StatefulWidget {
  const TicketOverview({super.key});

  @override
  State<TicketOverview> createState() => _TicketOverviewState();
}

class _TicketOverviewState extends State<TicketOverview> {
  int _selectedFilterIndex = 0;
  int _selectedBottomNavIndex = 1;

  final List<String> _filters = ['All', 'Open', 'In Progress', 'Resolved'];

  final List<Map<String, dynamic>> _allTickets = [
    {
      'id': 'TKT-8842',
      'title': 'Server failure in North Data Center',
      'description': 'The main production database is experiencing latency spikes affecting all...',
      'priority': 'HIGH PRIORITY',
      'priorityColor': Colors.red,
      'time': '2h ago',
      'status': 'OPEN',
      'statusColor': const Color(0xFF3B82F6),
    },
    {
      'id': 'TKT-8845',
      'title': 'VPN Access Request: Marketing Team',
      'description': 'Onboarding 3 new contractors who require secure access to internal CMS tools.',
      'priority': 'MEDIUM',
      'priorityColor': Colors.orange,
      'time': '5h ago',
      'status': 'OPEN',
      'statusColor': const Color(0xFF3B82F6),
    },
    {
      'id': 'TKT-8849',
      'title': 'Software Update: Design Suite',
      'description': 'Requesting deployment of the latest version of Creative Cloud for the UI team.',
      'priority': 'LOW',
      'priorityColor': Colors.grey,
      'time': '1d ago',
      'status': 'OPEN',
      'statusColor': const Color(0xFF3B82F6),
    },
    {
      'id': 'TKT-8851',
      'title': 'Email Delivery Delay',
      'description': 'Executive emails are being quarantined incorrectly by the spam filter.',
      'priority': 'HIGH PRIORITY',
      'priorityColor': Colors.red,
      'time': '3h ago',
      'status': 'OPEN',
      'statusColor': const Color(0xFF3B82F6),
    },
    {
      'id': 'TKT-8839',
      'title': 'Cloud Sync Latency Issues',
      'description': 'Users reporting slow sync times across all regions.',
      'priority': 'MEDIUM',
      'priorityColor': Colors.orange,
      'time': '5h ago',
      'status': 'IN PROGRESS',
      'statusColor': Colors.orange,
    },
  ];

  List<Map<String, dynamic>> get _filteredTickets {
    if (_selectedFilterIndex == 0) return _allTickets;
    String filterStatus = _filters[_selectedFilterIndex].toUpperCase();
    return _allTickets.where((t) => t['status'] == filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.menu, color: Color(0xFF1E293B)),
                  const Text(
                    'Digital Concierge',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFFFE4D6),
                    child: Icon(Icons.person, color: Colors.orange, size: 20),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tickets...',
                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF64748B)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // Filter Tabs
            const SizedBox(height: 24),
            Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF3F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: List.generate(_filters.length, (index) {
                  bool isSelected = _selectedFilterIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilterIndex = index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _filters[index],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'OPEN TICKETS OVERVIEW',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      letterSpacing: 1.1,
                    ),
                  ),
                  Icon(Icons.filter_list, size: 20, color: Color(0xFF64748B)),
                ],
              ),
            ),

            // Ticket List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _filteredTickets.length,
                itemBuilder: (context, index) {
                  final ticket = _filteredTickets[index];
                  return _buildTicketCard(ticket);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-ticket'),
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomNavIndex,
        onTap: (index) {
          setState(() => _selectedBottomNavIndex = index);
          if (index == 0) Navigator.pushReplacementNamed(context, '/admin-dashboard');
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3B82F6),
        unselectedItemColor: const Color(0xFF94A3B8),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined), label: 'TICKETS'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'CHAT'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'PROFILE'),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ticket['id'],
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'OPEN',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ticket['title'],
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Text(
            ticket['description'],
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.report_problem, size: 14, color: ticket['priorityColor']),
                  const SizedBox(width: 4),
                  Text(
                    ticket['priority'],
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: ticket['priorityColor']),
                  ),
                ],
              ),
              Text(
                ticket['time'],
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
