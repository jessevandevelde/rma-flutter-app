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
            const SnackBar(content: Text('Er is een fout opgetreden'), backgroundColor: Colors.red),
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
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'pictures/dmglogo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, color: Colors.black),
          ),
        ),
        title: const Text(
          'Login',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const CustomLabel(text: 'Email'),
                CustomTextField(
                  controller: _emailController,
                  hint: 'name@company.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Voer aub een email in';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const CustomLabel(text: 'Wachtwoord'),
                CustomTextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  hint: '••••••••',
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Voer aub een wachtwoord in';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1A56DB),
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                  child: const Text('Wachtwoord vergeten?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
                CustomButton(text: 'Log In', onPressed: _login, isLoading: _isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
