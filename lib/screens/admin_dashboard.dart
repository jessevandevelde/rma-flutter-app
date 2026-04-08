import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ApiService _apiService = ApiService();
  String _userName = '';
  int _openCount = 0;
  int _inProgressCount = 0;
  int _resolvedCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    // 1. Laad echte naam uit SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String storedName = prefs.getString('user_name') ?? '';
    final String email = prefs.getString('user_email') ?? '';
    
    // 2. Haal statistieken uit de database
    final stats = await _apiService.fetchDashboardData();

    if (mounted) {
      setState(() {
        if (storedName.isNotEmpty) {
          _userName = storedName;
        } else if (email.isNotEmpty) {
          // Fallback naar email als naam ontbreekt
          _userName = email.split('@')[0];
          _userName = _userName[0].toUpperCase() + _userName.substring(1);
        } else {
          _userName = 'Admin';
        }
        
        // Update de statistieken
        _openCount = stats['open'] ?? 0;
        _inProgressCount = stats['in_progress'] ?? 0;
        _resolvedCount = stats['resolved'] ?? 0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE4D6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'pictures/dmglogo.png',
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.phone_android, color: Colors.black54),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Digital Concierge',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.notifications_none_outlined, size: 28, color: Color(0xFF64748B)),
                  ],
                ),
                const SizedBox(height: 32),

                // Welcome Text - NU MET ECHTE NAAM
                Text(
                  'Welcome, $_userName',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Everything is running smoothly.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 32),

                // Status Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CURRENT STATUS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF64748B).withOpacity(0.7),
                        letterSpacing: 1.1,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'SYSTEM LIVE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Status Cards
                _buildStatusCard('Open', _openCount.toString(), const Color(0xFF3B82F6), Icons.confirmation_number_outlined, const Color(0xFFEFF6FF)),
                const SizedBox(height: 16),
                _buildStatusCard('In Progress', _inProgressCount.toString(), const Color(0xFFB45309), Icons.pending_outlined, const Color(0xFFFFFBEB)),
                const SizedBox(height: 16),
                _buildStatusCard('Resolved', _resolvedCount.toString(), const Color(0xFF10B981), Icons.check_circle_outline, const Color(0xFFECFDF5)),
                
                const SizedBox(height: 32),

                // Quick Actions
                Text(
                  'QUICK ACTIONS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF64748B).withOpacity(0.7),
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQuickAction(
                      'New Ticket', 
                      Icons.add, 
                      const Color(0xFFEFF6FF), 
                      const Color(0xFF3B82F6),
                      onTap: () => Navigator.pushNamed(context, '/create-ticket'),
                    ),
                    _buildQuickAction(
                      'View All', 
                      Icons.grid_view, 
                      const Color(0xFFF1F5F9), 
                      const Color(0xFF475569),
                      onTap: () {
                        // Afgehandeld door MainScreen
                      },
                    ),
                    _buildQuickAction(
                      'Insights', 
                      Icons.bar_chart, 
                      const Color(0xFFF1F5F9), 
                      const Color(0xFF475569),
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String count, Color color, IconData icon, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(
                    count,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color.withOpacity(0.7), size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, Color bgColor, Color iconColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
