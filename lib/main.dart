import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rma_app/screens/login_screen.dart';
import 'package:rma_app/screens/create_ticket.dart';
import 'package:rma_app/screens/ticket_overview.dart';
import 'package:rma_app/screens/forgot_password_screen.dart';
import 'package:rma_app/screens/admin_screen.dart';
import 'package:rma_app/screens/support_chat.dart';
import 'package:rma_app/screens/admin_dashboard.dart'; // Import admin dashboard
import 'package:rma_app/dev_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.backquote): const DevMenuIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DevMenuIntent: DevMenuAction(),
        },
        child: MaterialApp(
          title: 'RMA App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const LoginScreen(),
            '/create-ticket': (context) => const CreateTicketScreen(),
            '/ticket-overview': (context) => const TicketOverview(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/admin': (context) => const AdminScreen(),
            '/support-chat': (context) => const SupportChatPage(),
            '/admin-dashboard': (context) => const AdminDashboard(), // Register the route
          },
        ),
      ),
    );
  }
}
