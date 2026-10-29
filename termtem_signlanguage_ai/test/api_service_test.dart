import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:termtem_signlanguage_ai/services/api_service.dart';

void main() {
  final clip = PlatformFile(
    name: 'clip.mp4',
    size: 3,
    bytes: Uint8List.fromList([1, 2, 3]),
  );
  test('sends current bearer token to Go using video multipart field', () async {
    var token = 'first';
    final client = MockClient((request) async {
      expect(
        request.url.toString(),
        'http://localhost:8080/api/videos/process',
      );
      expect(request.headers['Authorization'], 'Bearer $token');
      expect(request.body, contains('name="video"; filename="clip.mp4"'));
      expect(request.body, isNot(contains('name="file";')));
      return http.Response(
        '{"success":true,"data":{"prediction":{"label":"test","confidence":0.8,"mode":"model"}}}',
        200,
      );
    });
    final api = ApiService(
      tokenProvider: () async => token,
      client: client,
      baseUrl: 'http://localhost:8080',
    );
    addTearDown(api.close);
    await api.uploadSelectedVideo(clip);
    token = 'refreshed';
    await api.uploadSelectedVideo(clip);
  });
  test('does not upload when authentication fails', () async {
    final api = ApiService(
      tokenProvider: () async => throw StateError('no session'),
      client: MockClient((_) async {
        fail('unauthenticated upload');
      }),
    );
    addTearDown(api.close);
    await expectLater(api.uploadSelectedVideo(clip), throwsStateError);
  });
  for (final status in [401, 413, 422, 502, 504]) {
    test('handles HTTP $status without exposing server details', () async {
      final api = ApiService(
        tokenProvider: () async => 'token',
        client: MockClient(
          (_) async => http.Response('private internal details', status),
        ),
      );
      addTearDown(api.close);
      await expectLater(
        api.uploadSelectedVideo(clip),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'status', status)
              .having((e) => e.message, 'message', isNot(contains('private'))),
        ),
      );
    });
  }
  test('rejects oversized upload before fetching token', () async {
    final api = ApiService(
      tokenProvider: () async {
        fail('should reject size first');
      },
    );
    addTearDown(api.close);
    await expectLater(
      api.uploadSelectedVideo(
        PlatformFile(
          name: 'big.mp4',
          size: 33 * 1024 * 1024,
          bytes: Uint8List(1),
        ),
      ),
      throwsA(isA<ApiException>()),
    );
  });
  test('rejects success response without prediction', () async {
    final api = ApiService(
      tokenProvider: () async => 'token',
      client: MockClient(
        (_) async => http.Response('{"success":true,"data":{}}', 200),
      ),
    );
    addTearDown(api.close);
    await expectLater(
      api.uploadSelectedVideo(clip),
      throwsA(isA<ApiException>()),
    );
  });
}
