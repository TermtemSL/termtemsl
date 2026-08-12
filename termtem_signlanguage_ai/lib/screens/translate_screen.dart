import 'dart:io';

import 'package:flutter/material.dart';
import '../shared/widgets/termtem_header.dart';
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

    return Container(
      color: const Color(0xFFF9F9FC),
      child: Column(
        children: [
          const TermtemHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Translate Signs',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1C1E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Capture gestures and turn them into words instantly.',
                    style: TextStyle(
                      color: Color(0xFF564338),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildUploadCard(),
                  
                  const SizedBox(height: 24),
                  
                  _buildResultCard(confidencePercent, confidenceColor, confidenceLevel),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      _buildQuickAction(Icons.history, 'Recent', '24 translations'),
                      const SizedBox(width: 16),
                      _buildQuickAction(Icons.star, 'Saved', '8 phrases'),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  _buildHintBubble(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E2E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: mode == 'mock'
                      ? const Color(0xFFFFDBC9)
                      : mode == 'error'
                          ? Colors.red[100]
                          : const Color(0xFF8AF5B3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: mode == 'mock'
                            ? const Color(0xFF9B4500)
                            : mode == 'error'
                                ? Colors.red
                                : const Color(0xFF006D3F),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      mode == 'mock'
                          ? 'MOCK MODE'
                          : mode == 'error'
                              ? 'ERROR'
                              : 'TSL AI',
                      style: TextStyle(
                        color: mode == 'mock'
                            ? const Color(0xFF9B4500)
                            : mode == 'error'
                                ? Colors.red[900]
                                : const Color(0xFF006D3F),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedVideo != null && !isLoading)
                InkWell(
                  onTap: clearSelectedVideo,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9FC),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E2E5)),
                    ),
                    child: const Icon(Icons.close, size: 16, color: Color(0xFF1A1C1E)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (videoController != null && videoController!.value.isInitialized)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: videoController!.value.size.width,
                          height: videoController!.value.size.height,
                          child: VideoPlayer(videoController!),
                        ),
                      ),
                    ),
                    IconButton(
                      iconSize: 60,
                      color: Colors.white.withOpacity(0.9),
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
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9FC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E2E5), style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFDBC9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isLoading ? Icons.hourglass_top : Icons.video_camera_front,
                      color: const Color(0xFF9B4500),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Upload or Record',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1C1E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Show your signs clearly within the frame for best results.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF564338),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFDBC9),
                    foregroundColor: const Color(0xFF9B4500),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoading ? null : pickVideoForReview,
                  child: Text(
                    selectedVideo == null ? 'Upload Video' : 'Change Video',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9B4500),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoading || selectedVideo == null ? null : uploadAndTranslate,
                  child: Text(
                    isLoading ? 'Processing...' : 'Start Translation',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String confidencePercent, Color confidenceColor, String confidenceLevel) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E2E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TRANSLATION RESULT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF564338),
                  letterSpacing: 1,
                ),
              ),
              Icon(Icons.copy, color: Colors.grey[400], size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            predictionText,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C1E),
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              LinearProgressIndicator(
                value: confidence.clamp(0.0, 1.0),
                backgroundColor: const Color(0xFFE2E2E5),
                color: confidenceColor,
                minHeight: 12,
                borderRadius: BorderRadius.circular(10),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FractionalTranslation(
                  translation: const Offset(0, -0.2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                confidenceLevel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: confidenceColor,
                ),
              ),
              Text(
                'MODE: $mode',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF564338),
                ),
              ),
            ],
          ),
          if (confidence > 0 && confidence < 0.4) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red[400], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Prediction may be inaccurate. Try recording a clearer video.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String title, String sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E2E5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFC6E7FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF006D3F)),
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
                      color: Color(0xFF1A1C1E),
                    ),
                  ),
                  Text(
                    sub,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF564338), fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHintBubble() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDBC9).withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFDBC9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: Color(0xFF9B4500), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 13, color: Color(0xFF564338), height: 1.4),
                children: [
                  TextSpan(text: 'Tip from Nong Termtem: ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9B4500))),
                  TextSpan(text: 'Make sure your hands are clearly visible and record in good lighting.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
