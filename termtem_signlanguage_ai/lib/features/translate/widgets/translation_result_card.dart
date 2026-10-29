import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Displays the translation result, confidence progress bar, and mode label.
///
/// Receives all display data as constructor parameters so the widget is
/// purely presentational — state remains in [TranslateScreen].
class TranslationResultCard extends StatelessWidget {
  final String predictionText;
  final double confidence;
  final String mode;
  final Color confidenceColor;
  final String confidenceLevel;

  const TranslationResultCard({
    super.key,
    required this.predictionText,
    required this.confidence,
    required this.mode,
    required this.confidenceColor,
    required this.confidenceLevel,
  });

  @override
  Widget build(BuildContext context) {
    final confidencePercent = (confidence * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceVariant),
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
          // ── header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TRANSLATION RESULT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSoft,
                  letterSpacing: 1,
                ),
              ),
              Icon(Icons.copy, color: Colors.grey[400], size: 20),
            ],
          ),
          const SizedBox(height: 16),

          // ── prediction text ──
          Text(
            predictionText,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 24),

          // ── confidence bar + percentage pill ──
          Stack(
            children: [
              LinearProgressIndicator(
                value: confidence.clamp(0.0, 1.0),
                backgroundColor: AppColors.surfaceVariant,
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

          // ── labels row ──
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
                  color: AppColors.textSoft,
                ),
              ),
            ],
          ),

          // ── low-confidence warning ──
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
}
