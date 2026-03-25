  import 'package:flutter/material.dart';
import 'package:rma_app/screens/login_screen.dart';
import 'package:rma_app/screens/create_ticket.dart';
import 'package:rma_app/screens/ticket_overview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RMA App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Start op de login pagina
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/create-ticket': (context) => CreateTicketScreen(),
        '/ticket-overview': (context) => const TicketOverview(),
      },
    );
  }
}
