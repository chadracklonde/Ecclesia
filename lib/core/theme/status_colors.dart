import 'package:flutter/material.dart';

/// Couleurs fonctionnelles de statut (vert/ambre/rouge d'état), adaptatives
/// clair/sombre. Comble la limite explicitement notée à l'audit de
/// l'Étape 2 : les maquettes statiques n'avaient pas vérifié l'inversion
/// des teintes en mode sombre — c'est fait ici, dans le vrai code.
enum AppStatus { fullMember, probation, absent }

class StatusColors {
  final Color background;
  final Color foreground;
  const StatusColors(this.background, this.foreground);
}

class AppStatusPalette {
  static StatusColors of(AppStatus status, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    switch (status) {
      case AppStatus.fullMember:
        return isDark
            ? const StatusColors(Color(0xFF27500A), Color(0xFFC0DD97))
            : const StatusColors(Color(0xFFEAF3DE), Color(0xFF173404));
      case AppStatus.probation:
        return isDark
            ? const StatusColors(Color(0xFF633806), Color(0xFFFAC775))
            : const StatusColors(Color(0xFFFAEEDA), Color(0xFF412402));
      case AppStatus.absent:
        return isDark
            ? const StatusColors(Color(0xFF5C2018), Color(0xFFF0A99C))
            : const StatusColors(Color(0xFFFBEAEA), Color(0xFF7B231C));
    }
  }
}
