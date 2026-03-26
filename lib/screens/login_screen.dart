import 'package:flutter/material.dart';
import 'package:rma_app/classes/authenticatie.dart';
import '../components/custom_button.dart';
import '../components/custom_label.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final Authenticatie _authService = Authenticatie();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // UITLEG: De 'bypass' is nu verwijderd. 
  // De app probeert nu ECHT verbinding te maken met je API.
  // Als de server niet aanstaat, krijg je nu een foutmelding te zien.
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _authService.login(
          _emailController.text,
          _passwordController.text,
        );

        setState(() {
          _isLoading = false;
        });

        if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
          // Succes: Ga naar het dashboard
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/ticket-overview');
          }
        } else {
          // Fout: Toon de melding van de server of een algemene fout
          if (mounted) {
            String errorMsg = "Server onbereikbaar of ongeldige gegevens";
            if (response?.data != null && response?.data['message'] != null) {
              errorMsg = response?.data['message'];
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login mislukt: $errorMsg'), backgroundColor: Colors.red),
            );
          }
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Netwerkfout: Controleer of je server aanstaat'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('RMA Login', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CustomLabel(text: 'Email'),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'jouw@email.nl'),
                validator: (value) => (value == null || value.isEmpty) ? 'Voer email in' : null,
              ),
              const SizedBox(height: 20),
              const CustomLabel(text: 'Wachtwoord'),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '••••••••'),
                validator: (value) => (value == null || value.isEmpty) ? 'Voer wachtwoord in' : null,
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: 'Log In',
                onPressed: _login,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
