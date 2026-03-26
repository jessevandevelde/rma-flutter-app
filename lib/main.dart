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
      debugShowCheckedModeBanner: false, // Haalt het rode 'debug' label weg
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // UITLEG: initialRoute '/' zorgt ervoor dat de app ALTIJD op het LoginScreen begint.
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/create-ticket': (context) => const CreateTicketScreen(),
        '/ticket-overview': (context) => const TicketOverview(),
      },
    );
  }
}
