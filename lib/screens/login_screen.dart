import 'package:flutter/material.dart';
import 'package:rma_app/classes/authenticatie.dart';
import 'package:dio/dio.dart';
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
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login succesvol!'),
                backgroundColor: Colors.green,
              ),
            );

            // Helper functie om recursief naar de sleutel te zoeken
            dynamic findValue(dynamic data, String key) {
              if (data is Map) {
                if (data.containsKey(key)) return data[key];
                for (var value in data.values) {
                  final found = findValue(value, key);
                  if (found != null) return found;
                }
              } else if (data is List) {
                for (var item in data) {
                  final found = findValue(item, key);
                  if (found != null) return found;
                }
              }
              return null;
            }

            final rawUserTypeId = findValue(response.data, 'user_type_id');
            final int? userType = int.tryParse(rawUserTypeId?.toString() ?? '');

            if (userType == 2) {
              Navigator.pushReplacementNamed(context, '/admin');
            } else {
              Navigator.pushReplacementNamed(context, '/ticket-overview');
            }
          }
        } else {
          if (mounted) {
            String errorMsg = "Login mislukt";
            if (response?.data != null && response?.data['message'] != null) {
              errorMsg = response?.data['message'];
            } else if (response?.statusMessage != null) {
              errorMsg = response!.statusMessage!;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMsg),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          String message = "Er is een fout opgetreden";
          if (e is DioException) {
            message = "Netwerkfout: ${e.message}";
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
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
                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Image.asset(
                        'pictures/dmglogo.png',
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, size: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Welcome back to your Digital Concierge',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email Input
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: CustomLabel(text: 'Email'),
                  ),
                  CustomTextField(
                    controller: _emailController,
                    hint: 'name@company.com',
                    prefixIcon: const Icon(Icons.person_outline),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || value.isEmpty) ? 'Enter email' : null,
                  ),
                  const SizedBox(height: 20),

                  // Wachtwoord Input
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: CustomLabel(text: 'Password'),
                  ),
                  CustomTextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    hint: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFF64748B),
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Enter password' : null,
                  ),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF1A56DB),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot-password');
                      },
                      child: const Text(
                        'Wachtwoord vergeten?',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
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
