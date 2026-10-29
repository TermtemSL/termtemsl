import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/app_config.dart';
import '../services/auth_scope.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.register = false});
  final bool register;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _register = false;
  bool _busy = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _register = widget.register;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit({bool google = false}) async {
    if (!google && !_form.currentState!.validate()) return;
    final auth = AuthScope.of(context);
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      if (google) {
        await auth.signInWithGoogle();
      } else if (_register) {
        final signedIn = await auth.signUp(
          _name.text,
          _email.text,
          _password.text,
        );
        if (!signedIn && mounted) {
          setState(() {
            _register = false;
            _password.clear();
            _confirm.clear();
            _message =
                'Check your email to confirm your account, then sign in.';
          });
        }
      } else {
        await auth.signIn(_email.text, _password.text);
      }
    } on AuthException catch (error) {
      if (mounted) setState(() => _message = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _message = 'Could not connect. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.sign_language, size: 56, color: Colors.teal),
                  const SizedBox(height: 16),
                  const Text(
                    'Nong Termtem',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _register
                        ? 'Create your account'
                        : 'Sign in to translate and practise signs',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (_register) ...[
                    TextFormField(
                      controller: _name,
                      enabled: !_busy,
                      decoration: const InputDecoration(labelText: 'Full name'),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter your name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _email,
                    enabled: !_busy,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) =>
                        v == null ||
                            !RegExp(
                              r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                            ).hasMatch(v.trim())
                        ? 'Enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    enabled: !_busy,
                    obscureText: true,
                    autofillHints: [
                      _register
                          ? AutofillHints.newPassword
                          : AutofillHints.password,
                    ],
                    decoration: const InputDecoration(labelText: 'Password'),
                    onFieldSubmitted: (_) {
                      if (!_busy) _submit();
                    },
                    validator: (v) => v == null || v.isEmpty
                        ? 'Enter your password'
                        : _register && v.length < 8
                        ? 'Use at least 8 characters'
                        : null,
                  ),
                  if (_register) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirm,
                      enabled: !_busy,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm password',
                      ),
                      validator: (v) =>
                          v != _password.text ? 'Passwords do not match' : null,
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (_message != null) ...[
                    Text(
                      _message!,
                      key: const Key('auth-message'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  FilledButton(
                    onPressed: _busy ? null : () => _submit(),
                    child: Text(
                      _busy
                          ? 'Please wait…'
                          : _register
                          ? 'Create account'
                          : 'Sign in',
                    ),
                  ),
                  if (AppConfig.googleEnabled)
                    OutlinedButton.icon(
                      onPressed: _busy ? null : () => _submit(google: true),
                      icon: const Icon(Icons.login),
                      label: const Text('Continue with Google'),
                    ),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                            _register = !_register;
                            _message = null;
                            _form.currentState!.reset();
                          }),
                    child: Text(
                      _register
                          ? 'Already have an account? Sign in'
                          : 'Create an account',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
