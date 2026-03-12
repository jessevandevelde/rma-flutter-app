import 'package:flutter/material.dart';

class TicketOverview extends StatelessWidget {
  const TicketOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Overzicht'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            print('Button ingedrukt!');
          },
          child: const Text('Bevestig Ticket'),
        ),
      ),
    );
  }
}
