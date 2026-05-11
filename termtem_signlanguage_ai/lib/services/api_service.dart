import 'dart:convert';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    } else {
      return 'http://10.0.2.2:8000';
    }
  }

  static Future<Map<String, dynamic>> uploadVideo() async {
    final result = await fp.FilePicker.pickFiles(
      type: fp.FileType.video,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      throw Exception('No video selected');
    }

    final file = result.files.first;

    if (file.bytes == null) {
      throw Exception('File bytes are empty');
    }

    final uri = Uri.parse('$baseUrl/api/video/upload');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      throw Exception('Upload failed: $responseBody');
    }
  }
}
