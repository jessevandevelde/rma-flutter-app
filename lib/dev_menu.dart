import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DevMenuIntent extends Intent {
  const DevMenuIntent();
}

class DevMenuAction extends Action<DevMenuIntent> {
  @override
  Object? invoke(DevMenuIntent intent) {
    final BuildContext? context = primaryFocus?.context;
    if (context != null) {
      showDialog(
        context: context,
        builder: (context) => const DevMenuDialog(),
      );
    }
    return null;
  }
}

class DevMenuDialog extends StatelessWidget {
  const DevMenuDialog({super.key});

  @override
  Widget build(BuildContext context) {
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
            label: 'Create Ticket (Placeholder)',
            onTap: () {
              // Placeholder for future implementation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create ticket logic not implemented yet.')),
              );
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
