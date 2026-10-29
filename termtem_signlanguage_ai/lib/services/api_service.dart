import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

class ApiService {
  ApiService({
    required this.tokenProvider,
    http.Client? client,
    String? baseUrl,
  }) : _client = client ?? http.Client(),
       _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;
  final Future<String> Function() tokenProvider;
  final http.Client _client;
  final String _baseUrl;

  static Future<fp.PlatformFile?> pickVideo() async {
    final result = await fp.FilePicker.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: ['mp4', 'mov', 'avi', 'mkv'],
      withData: true,
    );
    return result == null || result.files.isEmpty ? null : result.files.first;
  }

  Future<Map<String, dynamic>> uploadSelectedVideo(fp.PlatformFile file) async {
    if (file.size == 0 || file.bytes == null || file.bytes!.isEmpty) {
      throw const ApiException('Select a readable video.');
    }
    if (file.size > 32 * 1024 * 1024) {
      throw const ApiException('Video exceeds 32 MiB. Choose a shorter clip.');
    }
    final token = await tokenProvider();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/api/videos/process'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      http.MultipartFile.fromBytes('video', file.bytes!, filename: file.name),
    );
    try {
      final response = await (() async {
        final streamed = await _client.send(request);
        return http.Response.fromStream(streamed);
      })().timeout(const Duration(seconds: 135));
      if (response.statusCode != 200) {
        final message = switch (response.statusCode) {
          401 => 'Your session was rejected. Sign out and sign in again.',
          413 => 'Video exceeds the upload limit. Choose a shorter clip.',
          422 =>
            'Could not process video. Use a readable clip with visible hands and upper body.',
          502 => 'AI service is unavailable. Please try again later.',
          504 => 'Processing took too long. Try a shorter clip.',
          _ => 'Upload failed. Please try again.',
        };
        throw ApiException(message, statusCode: response.statusCode);
      }
      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic> ||
          body['success'] != true ||
          body['data'] is! Map ||
          body['data']['prediction'] is! Map) {
        throw const ApiException('The server returned an invalid result.');
      }
      return body;
    } on TimeoutException {
      throw const ApiException('Processing took too long. Try a shorter clip.');
    } on FormatException {
      throw const ApiException('The server returned an invalid result.');
    } on http.ClientException {
      throw const ApiException(
        'Cannot reach the server. Check your connection.',
      );
    }
  }

  void close() => _client.close();
}
