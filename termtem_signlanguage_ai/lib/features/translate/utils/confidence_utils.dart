import 'package:flutter/material.dart';

/// Returns a colour that visually represents [value] on a red→orange→green scale.
Color getConfidenceColor(double value) {
  if (value >= 0.75) return Colors.green;
  if (value >= 0.40) return Colors.orange;
  if (value > 0) return Colors.red;
  return Colors.grey;
}

/// Returns a human-readable confidence label for [value].
String getConfidenceLevel(double value) {
  if (value >= 0.75) return 'High confidence';
  if (value >= 0.40) return 'Medium confidence';
  if (value > 0) return 'Low confidence';
  return 'No confidence';
}
