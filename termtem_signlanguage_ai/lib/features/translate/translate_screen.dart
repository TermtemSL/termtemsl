import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:video_player/video_player.dart';

import '../../shared/widgets/termtem_header.dart';
import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';
import 'utils/confidence_utils.dart';
import 'widgets/video_upload_card.dart';
import 'widgets/translation_result_card.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/hint_bubble.dart';

/// Translate feature — root screen and state orchestrator.
///
/// Owns all business / state for this feature:
///   - [selectedVideo], [videoController]  (video lifecycle)
///   - [predictionText], [confidence], [mode]  (translation result)
///   - [isLoading]  (upload progress)
///   - [pickVideoForReview], [uploadAndTranslate], [clearSelectedVideo]
///
/// Extracted widgets ([VideoUploadCard], [TranslationResultCard],
/// [QuickActionCard], [HintBubble]) receive data + callbacks via constructor
/// parameters and contain no business logic.
class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  // ── State ──────────────────────────────────────────────────────────────────
  String predictionText = 'No translation yet';
  double confidence = 0.0;
  String mode = '-';
  bool isLoading = false;

  fp.PlatformFile? selectedVideo;
  VideoPlayerController? videoController;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

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

  void _togglePlayback() {
    setState(() {
      videoController!.value.isPlaying
          ? videoController!.pause()
          : videoController!.play();
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final confidenceColor = getConfidenceColor(confidence);
    final confidenceLevel = getConfidenceLevel(confidence);

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          const TermtemHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── page title ──────────────────────────────────────────
                  const Text(
                    'Translate Signs',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Capture gestures and turn them into words instantly.',
                    style: TextStyle(color: AppColors.textSoft, fontSize: 16),
                  ),
                  const SizedBox(height: 32),

                  // ── upload card ─────────────────────────────────────────
                  VideoUploadCard(
                    selectedVideo: selectedVideo,
                    videoController: videoController,
                    mode: mode,
                    isLoading: isLoading,
                    onPickVideo: pickVideoForReview,
                    onTranslate: isLoading || selectedVideo == null
                        ? null
                        : uploadAndTranslate,
                    onClear: clearSelectedVideo,
                    onTogglePlayback: _togglePlayback,
                  ),
                  const SizedBox(height: 24),

                  // ── result card ─────────────────────────────────────────
                  TranslationResultCard(
                    predictionText: predictionText,
                    confidence: confidence,
                    mode: mode,
                    confidenceColor: confidenceColor,
                    confidenceLevel: confidenceLevel,
                  ),
                  const SizedBox(height: 24),

                  // ── quick actions row ───────────────────────────────────
                  Row(
                    children: const [
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.history,
                          title: 'Recent',
                          subtitle: '24 translations',
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.star,
                          title: 'Saved',
                          subtitle: '8 phrases',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── hint bubble ─────────────────────────────────────────
                  const HintBubble(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
