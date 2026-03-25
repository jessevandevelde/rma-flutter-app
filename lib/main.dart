import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/create_ticket.dart';
import 'screens/ticket_overview.dart';
import 'core/constants/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RMA App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.backgroundGray,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
        ),
        useMaterial3: true,
      ),
      // We starten nu op het inlogscherm
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/create-ticket': (context) => const CreateTicketScreen(),
        '/ticket-overview': (context) => const TicketOverview(),
      },
    );
  }
}
