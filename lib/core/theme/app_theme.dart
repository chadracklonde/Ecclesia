import 'package:flutter/material.dart';

/// Thèmes clair/sombre basés sur la charte graphique officielle UMC
/// (Étape 2) : rouge `#E4002B` comme couleur primaire.
class AppTheme {
  static const umcRed = Color(0xFFE4002B);
  static const errorRed = Color(0xFFC0392B);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: umcRed,
      brightness: Brightness.light,
      error: errorRed,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: Brightness.light,
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: umcRed,
      brightness: Brightness.dark,
      error: errorRed,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: Brightness.dark,
    );
  }
}
