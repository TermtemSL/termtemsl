import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';

Future<VideoPlayerController?> createVideoPreview(PlatformFile file) async {
  if (file.bytes == null) return null;
  final url = web.URL.createObjectURL(web.Blob([file.bytes!.toJS].toJS));
  final controller = VideoPlayerController.networkUrl(Uri.parse(url));
  try {
    await controller.initialize();
    await controller.setLooping(true);
    return controller;
  } catch (_) {
    await controller.dispose();
    return null;
  } finally {
    web.URL.revokeObjectURL(url);
  }
}
