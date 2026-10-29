import 'package:flutter/foundation.dart';

class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  static const googleEnabled = bool.fromEnvironment('ENABLE_GOOGLE_LOGIN');
  static const authRedirect = String.fromEnvironment(
    'AUTH_REDIRECT_URL',
    defaultValue: 'io.termtemsl.app://login-callback/',
  );
  static String get apiBaseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) return configured.replaceAll(RegExp(r'/+$'), '');
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8080'
        : 'http://127.0.0.1:8080';
  }
}
