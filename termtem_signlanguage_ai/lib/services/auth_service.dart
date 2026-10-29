import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/app_config.dart';

abstract class AuthController extends ChangeNotifier {
  User? get user;
  bool get isSignedIn;
  Future<void> signIn(String email, String password);
  Future<bool> signUp(String name, String email, String password);
  Future<void> signInWithGoogle();
  Future<String> accessToken();
  Future<void> signOut();
}

class AuthService extends AuthController {
  AuthService(this.client) {
    _subscription = client.auth.onAuthStateChange.listen(
      (event) {
        notifyListeners();
      },
      onError: (Object error) {
        // A network refresh failure must not erase the persisted session.
        notifyListeners();
      },
    );
  }
  final SupabaseClient client;
  late final StreamSubscription<AuthState> _subscription;
  @override
  User? get user => client.auth.currentUser;
  @override
  bool get isSignedIn => client.auth.currentSession != null;

  @override
  Future<void> signIn(String email, String password) async {
    await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<bool> signUp(String name, String email, String password) async {
    final result = await client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': name.trim()},
    );
    return result.session != null;
  }

  @override
  Future<void> signInWithGoogle() async {
    final launched = await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? Uri.base.origin : AppConfig.authRedirect,
    );
    if (!launched) throw const AuthException('Could not open Google sign-in.');
  }

  @override
  Future<String> accessToken() async {
    var session = client.auth.currentSession;
    if (session == null) {
      throw const AuthException('Please sign in to continue.');
    }
    if (session.isExpired) {
      session = (await client.auth.refreshSession()).session;
    }
    if (session == null) throw const AuthException('Please sign in again.');
    return session.accessToken;
  }

  @override
  Future<void> signOut() => client.auth.signOut(scope: SignOutScope.local);

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
