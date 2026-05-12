import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:video_player/video_player.dart';

import '../services/api_service.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  String predictionText = 'No translation yet';
  double confidence = 0.0;
  String mode = '-';
  bool isLoading = false;

  fp.PlatformFile? selectedVideo;
  VideoPlayerController? videoController;

  Color getConfidenceColor(double value) {
    if (value >= 0.75) return Colors.green;
    if (value >= 0.40) return Colors.orange;
    if (value > 0) return Colors.red;
    return Colors.grey;
  }

  String getConfidenceLevel(double value) {
    if (value >= 0.75) return 'High confidence';
    if (value >= 0.40) return 'Medium confidence';
    if (value > 0) return 'Low confidence';
    return 'No confidence';
  }

  Future<void> pickVideoForReview() async {
    final file = await ApiService.pickVideo();

    if (file == null) return;

    await videoController?.dispose();

    VideoPlayerController? controller;

    if (file.path != null) {
      controller = VideoPlayerController.file(File(file.path!));
      await controller.initialize();
      await controller.setLooping(true);
    }

    setState(() {
      selectedVideo = file;
      videoController = controller;
      predictionText = 'Video selected. Ready to translate.';
      confidence = 0.0;
      mode = '-';
    });
  }

  Future<void> uploadAndTranslate() async {
    if (selectedVideo == null) {
      await pickVideoForReview();
      if (selectedVideo == null) return;
    }

    setState(() {
      isLoading = true;
      predictionText = 'Processing video...';
      confidence = 0.0;
      mode = '-';
    });

    try {
      final response = await ApiService.uploadSelectedVideo(selectedVideo!);
      final prediction = response['data']['prediction'];

      setState(() {
        predictionText = prediction['label'] ?? 'Unknown';
        confidence = (prediction['confidence'] ?? 0.0).toDouble();
        mode = prediction['mode'] ?? '-';
      });
    } catch (e) {
      setState(() {
        predictionText = 'Upload failed';
        confidence = 0.0;
        mode = 'error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> clearSelectedVideo() async {
    await videoController?.dispose();

    setState(() {
      selectedVideo = null;
      videoController = null;
      predictionText = 'No translation yet';
      confidence = 0.0;
      mode = '-';
    });
  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final confidencePercent = (confidence * 100).toStringAsFixed(0);
    final confidenceColor = getConfidenceColor(confidence);
    final confidenceLevel = getConfidenceLevel(confidence);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Translate',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: -2,
              ),
            ),
            const Text(
              'ASL to Text Sign Language AI Assistant',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),

            SizedBox(
              height: 330,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (videoController != null &&
                              videoController!.value.isInitialized)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: SizedBox(
                                width: 290,
                                height: 170,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox.expand(
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                          width:
                                              videoController!.value.size.width,
                                          height: videoController!
                                              .value
                                              .size
                                              .height,
                                          child: VideoPlayer(videoController!),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      iconSize: 60,
                                      color: Colors.white,
                                      icon: Icon(
                                        videoController!.value.isPlaying
                                            ? Icons.pause_circle_filled
                                            : Icons.play_circle_fill,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          videoController!.value.isPlaying
                                              ? videoController!.pause()
                                              : videoController!.play();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isLoading
                                    ? Icons.hourglass_top
                                    : Icons.video_file,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),

                          const SizedBox(height: 18),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 14,
                              ),
                              shape: const StadiumBorder(),
                              elevation: 0,
                            ),
                            onPressed: isLoading ? null : pickVideoForReview,
                            child: Text(
                              selectedVideo == null
                                  ? 'Choose video'
                                  : 'Change video',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 14,
                              ),
                              shape: const StadiumBorder(),
                              elevation: 0,
                            ),
                            onPressed: isLoading || selectedVideo == null
                                ? null
                                : uploadAndTranslate,
                            child: Text(
                              isLoading ? 'Processing...' : 'Translate',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      bottom: 20,
                      left: 24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isLoading ? Colors.orange : Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              mode == 'mock'
                                  ? 'MOCK MODE'
                                  : mode == 'error'
                                  ? 'ERROR'
                                  : 'TSL AI',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      top: 24,
                      right: 24,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          onPressed: isLoading ? null : pickVideoForReview,
                          icon: const Icon(
                            Icons.video_library,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 84,
                      right: 24,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          onPressed: selectedVideo == null || isLoading
                              ? null
                              : clearSelectedVideo,
                          icon: const Icon(Icons.close, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TRANSLATION RESULT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1,
                        ),
                      ),
                      Icon(Icons.copy, color: Colors.grey, size: 18),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    '"$predictionText"',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Stack(
                    children: [
                      LinearProgressIndicator(
                        value: confidence.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[300],
                        color: confidenceColor,
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: confidenceColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$confidencePercent%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        confidenceLevel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: confidenceColor,
                        ),
                      ),
                      Text(
                        'MODE: $mode',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  if (confidence > 0 && confidence < 0.4) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Prediction may be inaccurate. Try recording a clearer video.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                _buildQuickAction(Icons.history, 'Recent', '24 translations'),
                const SizedBox(width: 16),
                _buildQuickAction(Icons.star, 'Saved', '8 phrases'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String title, String sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    sub,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
