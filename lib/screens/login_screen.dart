import 'package:flutter/material.dart';
import 'package:rma_app/classes/authenticatie.dart';
import '../components/custom_button.dart';
import '../components/custom_label.dart';
import '../components/custom_text_field.dart';

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

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final response = await _authService.login(
          _emailController.text,
          _passwordController.text,
        );

        setState(() => _isLoading = false);

        if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
          if (mounted) {
            final data = response.data;
            
            // Haal de user_type_id op uit de response
            final user = data['user'];
            int userTypeId = 1; // Standaard Customer

            if (user != null && user['user_type_id'] != null) {
              userTypeId = int.tryParse(user['user_type_id'].toString()) ?? 1;
            } else if (data['user_type_id'] != null) {
              userTypeId = int.tryParse(data['user_type_id'].toString()) ?? 1;
            }

            debugPrint('--- LOGIN RESULTAAT ---');
            debugPrint('User Type ID: $userTypeId');

            // STRIKTE DATABASE LOGICA:
            // Alleen 2 gaat naar Admin. 1 en de rest gaan naar Customer.
            if (userTypeId == 2) {
              debugPrint('ADMIN -> /main');
              Navigator.pushReplacementNamed(context, '/main');
            } else {
              debugPrint('CUSTOMER -> /ticket-overview');
              Navigator.pushReplacementNamed(context, '/ticket-overview');
            }
          }
        } else {
          if (mounted) {
            String errorMsg = "Login mislukt";
            if (response?.data != null && response?.data['message'] != null) {
              errorMsg = response?.data['message'];
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
            );
          }
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Er is een fout opgetreden: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Image.asset('pictures/dmglogo.png',
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, size: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text('Login', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 8),
                  const Text('Welcome back to your Digital Concierge', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Color(0xFF64748B))),
                  const SizedBox(height: 40),

                  const Align(alignment: Alignment.centerLeft, child: CustomLabel(text: 'Email')),
                  CustomTextField(
                    controller: _emailController,
                    hint: 'name@company.com',
                    prefixIcon: const Icon(Icons.person_outline),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || value.isEmpty) ? 'Enter email' : null,
                  ),
                  const SizedBox(height: 20),

                  const Align(alignment: Alignment.centerLeft, child: CustomLabel(text: 'Password')),
                  CustomTextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    hint: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF64748B)),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Enter password' : null,
                  ),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                      child: const Text('Wachtwoord vergeten?', style: TextStyle(color: Color(0xFF1A56DB), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Log In',
                    onPressed: _login,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
