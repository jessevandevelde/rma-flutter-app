import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:rma_app/classes/authenticatie.dart';

class DevMenuIntent extends Intent {
  const DevMenuIntent();
}

class DevMenuAction extends Action<DevMenuIntent> {
  static bool _isVisible = false;

  @override
  Object? invoke(DevMenuIntent intent) {
    final BuildContext? context = primaryFocus?.context;
    if (context != null && !_isVisible) {
      _isVisible = true;
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => const DevMenuDialog(),
      ).then((_) => _isVisible = false);
    }
    return null;
  }
}

class DevMenuDialog extends StatelessWidget {
  const DevMenuDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // Dynamic base URL for different platforms
    String baseUrl = 'http://localhost:8000';
    if (!kIsWeb && Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:8000';
    }

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.developer_mode, color: Colors.red),
          SizedBox(width: 10),
          Text('Developer Menu'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DevMenuButton(
            icon: Icons.chat_bubble_outline,
            label: 'Open Chat (ID: 2276)',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/support-chat',
                arguments: '2276',
              );
            },
          ),
          const SizedBox(height: 10),
          _DevMenuButton(
            icon: Icons.add_circle_outline,
            label: 'Create Ticket (RMM-100654)',
            onTap: () {
              Navigator.pop(context);
              // Updated URL format to use curly braces as requested
              final String mockUrl = '$baseUrl/api/ticket{RMM-100654}';
              
              Navigator.pushNamed(
                context,
                '/create-ticket',
                arguments: mockUrl,
              );
            },
          ),
          const SizedBox(height: 10),
          _DevMenuButton(
            icon: Icons.logout,
            label: 'Logout',
            onTap: () async {
              Navigator.pop(context); // Close dialog
              final auth = Authenticatie();
              await auth.logout();
              if (context.mounted) {
                // Navigate back to login and clear navigation stack
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _DevMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DevMenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
