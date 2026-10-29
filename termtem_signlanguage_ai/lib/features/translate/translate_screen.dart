import 'utils/video_preview.dart';
import '../../services/auth_scope.dart';

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
  bool isPicking = false;
  ApiService? _api;

  fp.PlatformFile? selectedVideo;
  VideoPlayerController? videoController;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _api?.close();
    videoController?.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> pickVideoForReview() async {
    if (isPicking || isLoading) return;
    setState(() => isPicking = true);
    try {
      final file = await ApiService.pickVideo();
      if (file == null || !mounted) return;
      if (file.size > 32 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video exceeds 32 MiB. Choose a shorter clip.'),
          ),
        );
        return;
      }
      final controller = await createVideoPreview(file);
      if (!mounted) {
        await controller?.dispose();
        return;
      }
      final previous = videoController;
      setState(() {
        selectedVideo = file;
        videoController = controller;
        predictionText = 'Video selected. Ready to translate.';
        confidence = 0;
        mode = '-';
      });
      await previous?.dispose();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the selected video.')),
        );
      }
    } finally {
      if (mounted) setState(() => isPicking = false);
    }
  }

  Future<void> uploadAndTranslate() async {
    if (isLoading || isPicking) return;
    if (selectedVideo == null) {
      await pickVideoForReview();
      if (selectedVideo == null) return;
    }

    if (!mounted) return;
    final auth = AuthScope.of(context);
    _api ??= ApiService(tokenProvider: auth.accessToken);
    setState(() {
      isLoading = true;
      predictionText = 'Processing video...';
      confidence = 0.0;
      mode = '-';
    });

    try {
      final response = await _api!.uploadSelectedVideo(selectedVideo!);
      if (!mounted) return;
      final prediction = response['data']['prediction'];

      setState(() {
        predictionText = prediction['label'] ?? 'Unknown';
        confidence = (prediction['confidence'] ?? 0.0).toDouble();
        mode = prediction['mode'] ?? '-';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        predictionText = e is ApiException
            ? e.message
            : 'Could not process video. Please sign in again or retry.';
        confidence = 0.0;
        mode = 'error';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> clearSelectedVideo() async {
    if (isLoading || isPicking) return;
    final previous = videoController;
    setState(() {
      selectedVideo = null;
      videoController = null;
      predictionText = 'No translation yet';
      confidence = 0.0;
      mode = '-';
    });
    await previous?.dispose();
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
                    isLoading: isLoading || isPicking,
                    onPickVideo: pickVideoForReview,
                    onTranslate: isLoading || isPicking || selectedVideo == null
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
