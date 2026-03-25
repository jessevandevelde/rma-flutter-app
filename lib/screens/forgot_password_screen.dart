import 'package:flutter/material.dart';
import 'package:rma_app/classes/authenticatie.dart';
import '../components/custom_button.dart';
import '../components/custom_label.dart';
import '../components/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final Authenticatie _authService = Authenticatie();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final response = await _authService.forgotPassword(_emailController.text);

      setState(() {
        _isLoading = false;
      });

      if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wachtwoord reset link verzonden naar je email!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Terug naar login
        }
      } else {
        if (mounted) {
          String errorMsg = "Kon geen link verzenden";
          if (response?.data != null && response?.data['message'] != null) {
            errorMsg = response?.data['message'];
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reset Wachtwoord',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Vul je emailadres in om een wachtwoord reset link te ontvangen.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const CustomLabel(text: 'Email'),
                CustomTextField(
                  controller: _emailController,
                  hint: 'name@company.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Voer aub een email in';
                    if (!value.contains('@')) return 'Voer een geldig emailadres in';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Stuur Reset Link',
                  onPressed: _sendResetLink,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
