import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';

Future<VideoPlayerController?> createVideoPreview(PlatformFile file) async {
  if (file.path == null) return null;
  final controller = VideoPlayerController.file(File(file.path!));
  try {
    await controller.initialize();
    await controller.setLooping(true);
    return controller;
  } catch (_) {
    await controller.dispose();
    return null;
  }
}
