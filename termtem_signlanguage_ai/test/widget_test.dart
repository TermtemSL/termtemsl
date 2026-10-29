import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:termtem_signlanguage_ai/main.dart';
import 'package:termtem_signlanguage_ai/screens/login_screen.dart';
import 'package:termtem_signlanguage_ai/screens/main_screen.dart';
import 'package:termtem_signlanguage_ai/services/auth_service.dart';

class FakeAuth extends AuthController {
  bool signedIn = false;
  bool confirmationRequired = false;
  String? error;
  @override
  bool get isSignedIn => signedIn;
  @override
  User? get user => signedIn
      ? User(
          id: 'test-user',
          appMetadata: {},
          userMetadata: {'full_name': 'Test Member'},
          aud: 'authenticated',
          email: 'member@example.com',
          createdAt: '2026-01-01T00:00:00Z',
        )
      : null;
  @override
  Future<void> signIn(String email, String password) async {
    if (error != null) throw AuthException(error!);
    signedIn = true;
    notifyListeners();
  }

  @override
  Future<bool> signUp(String name, String email, String password) async {
    if (confirmationRequired) return false;
    signedIn = true;
    notifyListeners();
    return true;
  }

  @override
  Future<void> signInWithGoogle() async {}
  @override
  Future<String> accessToken() async => 'test-token';
  @override
  Future<void> signOut() async {
    signedIn = false;
    notifyListeners();
  }
}

void main() {
  testWidgets(
    'login gates screens, displays auth errors, and logout clears profile',
    (tester) async {
      final auth = FakeAuth();
      addTearDown(auth.dispose);
      await tester.pumpWidget(MyApp(auth: auth));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(MainScreen), findsNothing);
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid email'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'member@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      auth.error = 'Invalid login credentials';
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Invalid login credentials'), findsOneWidget);
      auth.error = null;
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();
      expect(find.byType(MainScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.account_circle_outlined));
      await tester.pumpAndSettle();
      expect(find.text('member@example.com'), findsWidgets);
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Sign out'));
      await tester.tap(find.widgetWithText(FilledButton, 'Sign out'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(MainScreen), findsNothing);
      expect(find.text('member@example.com'), findsNothing);
    },
  );

  testWidgets('restored session opens main screen', (tester) async {
    final auth = FakeAuth()..signedIn = true;
    addTearDown(auth.dispose);
    await tester.pumpWidget(MyApp(auth: auth));
    await tester.pumpAndSettle();
    expect(find.byType(MainScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets(
    'signup requiring email confirmation stays outside main screens',
    (tester) async {
      final auth = FakeAuth()..confirmationRequired = true;
      addTearDown(auth.dispose);
      await tester.pumpWidget(MyApp(auth: auth));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create an account'));
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Member');
      await tester.enterText(fields.at(1), 'member@example.com');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password123');
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Create account'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pumpAndSettle();
      expect(
        find.text('Check your email to confirm your account, then sign in.'),
        findsOneWidget,
      );
      expect(find.byType(MainScreen), findsNothing);
    },
  );
}
