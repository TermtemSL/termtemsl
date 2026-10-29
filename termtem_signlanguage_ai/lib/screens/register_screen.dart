import 'package:flutter/material.dart';
import 'login_screen.dart';

// Registration is available through "Create an account" on the auth screen.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  @override
  Widget build(BuildContext context) => const LoginScreen(register: true);
}
