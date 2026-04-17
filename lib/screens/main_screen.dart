import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'ticket_overview.dart';
import 'support_chat.dart'; // ← jouw bestaande chat pagina

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  // Index 0 → HOME      → AdminDashboard
  // Index 1 → TICKETS   → TicketOverview
  // Index 2 → CHAT      → SupportChatPage
  // Index 3 → PROFILE   → placeholder
  final List<Widget> _pages = [
    const AdminDashboard(),
    const TicketOverview(),
    const SupportChatPage(),                                  // ← index 2
    const Center(child: Text('Profile Page - Coming Soon')), // ← index 3
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF3B82F6),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled),                label: 'HOME'),    // → index 0
            BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined),label: 'TICKETS'), // → index 1
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline),         label: 'CHAT'),    // → index 2
            BottomNavigationBarItem(icon: Icon(Icons.person_outline),              label: 'PROFILE'), // → index 3
          ],
        ),
      ),
    );
  }
}