import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/auth_scope.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AppConfig.supabaseUrl.isEmpty || AppConfig.supabaseKey.isEmpty) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Supabase configuration is missing. See the Flutter README.',
            ),
          ),
        ),
      ),
    );
    return;
  }
  try {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseKey,
    );
    runApp(MyApp(auth: AuthService(Supabase.instance.client)));
  } catch (_) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Unable to start sign-in. Check your connection and restart the app.',
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.auth});
  final AuthController auth;
  @override
  Widget build(BuildContext context) => AuthScope(
    auth: auth,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Termtem',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: ListenableBuilder(
        listenable: auth,
        builder: (context, _) => Navigator(
          // Replacing this navigator also clears protected profile routes on logout.
          key: ValueKey(auth.isSignedIn ? auth.user!.id : 'signed-out'),
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (_) =>
                auth.isSignedIn ? const MainScreen() : const LoginScreen(),
          ),
        ),
      ),
    ),
  );
}
