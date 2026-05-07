import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nong Termtem',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1, color: Colors.black),
              ),
              const SizedBox(height: 40),
              const Text(
                'Create Account',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -2, color: Colors.black),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join Termtem and let Termtem เติมเต็ม your life',
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
              const SizedBox(height: 48),
              
              // Full Name Field
              _buildInputField(label: 'FULL NAME', hint: 'John Doe'),
              const SizedBox(height: 24),

              // Email Field
              _buildInputField(label: 'EMAIL ADDRESS', hint: 'name@example.com'),
              const SizedBox(height: 24),

              // Password Field
              _buildInputField(label: 'PASSWORD', hint: '••••••••', isPassword: true),
              const SizedBox(height: 24),

              // Confirm Password Field
              _buildInputField(label: 'CONFIRM', hint: '••••••••', isPassword: true),
              
              const SizedBox(height: 48),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Register', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?', style: TextStyle(color: Colors.grey)),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      },
                      child: const Text('Login screen', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({required String label, required String hint, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }
}