import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:termtem_signlanguage_ai/services/auth_service.dart';

String testToken(int seconds) {
  String encode(Map<String, dynamic> value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${encode({'alg': 'HS256', 'typ': 'JWT'})}.${encode({'sub': 'test-user', 'exp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + seconds})}.test';
}

void main() {
  test('Supabase sign-in, refresh before upload, and sign-out', () async {
    final firstToken = testToken(3600);
    final refreshed = testToken(7200);
    var refreshes = 0;
    final client = SupabaseClient(
      'https://example.supabase.co',
      'public-test-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        if (request.url.path.endsWith('/logout')) {
          return http.Response('{}', 204);
        }
        expect(request.url.path, '/auth/v1/token');
        final refreshing =
            request.url.queryParameters['grant_type'] == 'refresh_token';
        if (refreshing) {
          refreshes++;
          expect(jsonDecode(request.body)['refresh_token'], 'test-refresh');
        } else {
          expect(jsonDecode(request.body)['email'], 'member@example.com');
          expect(jsonDecode(request.body)['password'], 'password123');
        }
        return http.Response(
          jsonEncode({
            'access_token': refreshing ? refreshed : firstToken,
            'refresh_token': 'test-refresh',
            'token_type': 'bearer',
            'expires_in': 3600,
            'user': {
              'id': 'test-user',
              'aud': 'authenticated',
              'email': 'member@example.com',
              'created_at': '2026-01-01T00:00:00Z',
              'app_metadata': {},
              'user_metadata': {},
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    final auth = AuthService(client);
    addTearDown(() async {
      auth.dispose();
      await client.dispose();
    });
    await expectLater(auth.accessToken(), throwsA(isA<AuthException>()));
    await auth.signIn(' member@example.com ', 'password123');
    expect(auth.isSignedIn, isTrue);
    expect(await auth.accessToken(), firstToken);
    client.auth.currentSession!.expiresAt =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 - 60;
    expect(await auth.accessToken(), refreshed);
    expect(refreshes, 1);
    await auth.signOut();
    expect(auth.isSignedIn, isFalse);
    await expectLater(auth.accessToken(), throwsA(isA<AuthException>()));
  });
}
