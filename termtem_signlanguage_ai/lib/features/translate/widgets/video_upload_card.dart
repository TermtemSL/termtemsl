import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_colors.dart';

/// A card that lets the user upload a video and preview it before translating.
///
/// Contains inline sub-pieces:
///  - [_ModeBadge]   — mode indicator pill (mock / error / TSL AI)
///  - video preview  — [VideoPlayer] overlaid with a play/pause button
///  - placeholder    — shown when no video is selected
///
/// These three sub-pieces are kept inline because they are exclusively used
/// inside this widget and are each only ~15-40 lines long.
class VideoUploadCard extends StatelessWidget {
  final fp.PlatformFile? selectedVideo;
  final VideoPlayerController? videoController;
  final String mode;
  final bool isLoading;

  /// Called when the user taps the upload / change-video button.
  final VoidCallback onPickVideo;

  /// Called when the user taps translate.
  final VoidCallback? onTranslate;

  /// Called when the user taps the ✕ clear button.
  final VoidCallback onClear;

  /// Called when the user toggles play/pause inside the video preview.
  final VoidCallback onTogglePlayback;

  const VideoUploadCard({
    super.key,
    required this.selectedVideo,
    required this.videoController,
    required this.mode,
    required this.isLoading,
    required this.onPickVideo,
    required this.onTranslate,
    required this.onClear,
    required this.onTogglePlayback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceVariant),
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
          // ── header row: mode badge + optional clear button ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ModeBadge(mode: mode),
              if (selectedVideo != null && !isLoading)
                InkWell(
                  onTap: onClear,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surfaceVariant),
                    ),
                    child: const Icon(Icons.close, size: 16, color: AppColors.textDark),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // ── video preview OR placeholder ──
          if (videoController != null && videoController!.value.isInitialized)
            _VideoPreview(
              controller: videoController!,
              onTogglePlayback: onTogglePlayback,
            )
          else
            _VideoPlaceholder(isLoading: isLoading),

          const SizedBox(height: 24),

          // ── action buttons ──
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoading ? null : onPickVideo,
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
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: onTranslate,
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
}

// ─────────────────────────────────────────────
// Inline sub-pieces (kept in the same file)
// ─────────────────────────────────────────────

/// Small pill badge that shows the current translation mode.
class _ModeBadge extends StatelessWidget {
  final String mode;

  const _ModeBadge({required this.mode});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color dot;
    final Color text;
    final String label;

    if (mode == 'mock') {
      bg = AppColors.primaryLight;
      dot = AppColors.primary;
      text = AppColors.primary;
      label = 'MOCK MODE';
    } else if (mode == 'error') {
      bg = Colors.red.shade100;
      dot = Colors.red;
      text = Colors.red.shade900;
      label = 'ERROR';
    } else {
      bg = AppColors.secondaryLight;
      dot = AppColors.secondary;
      text = AppColors.secondary;
      label = 'TSL AI';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// Displays the selected video with a play/pause overlay button.
class _VideoPreview extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback onTogglePlayback;

  const _VideoPreview({
    required this.controller,
    required this.onTogglePlayback,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
            IconButton(
              iconSize: 60,
              color: Colors.white.withOpacity(0.9),
              icon: Icon(
                controller.value.isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_fill,
              ),
              onPressed: onTogglePlayback,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state shown when no video has been selected yet.
class _VideoPlaceholder extends StatelessWidget {
  final bool isLoading;

  const _VideoPlaceholder({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLoading ? Icons.hourglass_top : Icons.video_camera_front,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Upload or Record',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Show your signs clearly within the frame for best results.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSoft),
          ),
        ],
      ),
    );
  }
}
