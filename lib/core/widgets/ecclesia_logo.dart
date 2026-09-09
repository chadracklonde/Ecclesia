import 'package:flutter/material.dart';

/// Icône Ecclesia — reproduit fidèlement `assets/logo/ecclesia_icon.svg`
/// (logo validé le 09/09/2026) en widgets Flutter natifs plutôt que via
/// un paquet SVG (ex. `flutter_svg`) non vérifiable dans ce sandbox.
/// Les coordonnées reproduisent exactement le SVG source, mises à
/// l'échelle sur un espace logique 380×380 (même repère que le fichier
/// source, pour qu'un futur ajustement du SVG reste facile à reporter ici).
class EcclesiaIcon extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const EcclesiaIcon({
    super.key,
    this.size = 96,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _EcclesiaIconPainter(
        backgroundColor: backgroundColor ?? const Color(0xFFFBF8F3),
        foregroundColor: foregroundColor ?? const Color(0xFFE4002B),
      ),
    );
  }
}

class _EcclesiaIconPainter extends CustomPainter {
  final Color backgroundColor;
  final Color foregroundColor;

  _EcclesiaIconPainter({
    required this.backgroundColor,
    required this.foregroundColor,
  });

  static const double _logicalSize = 380;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _logicalSize;
    canvas.save();
    canvas.scale(scale);

    final bgPaint = Paint()..color = backgroundColor;
    final fgPaint = Paint()..color = foregroundColor;

    // Fond carré arrondi.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(40, 40, 300, 300),
        const Radius.circular(64),
      ),
      bgPaint,
    );

    // Toit principal.
    canvas.drawPath(
      Path()
        ..moveTo(95, 230)
        ..lineTo(285, 230)
        ..lineTo(190, 170)
        ..close(),
      fgPaint,
    );

    // Corps du bâtiment.
    canvas.drawRect(const Rect.fromLTWH(110, 230, 160, 80), fgPaint);

    // Clocher (tour).
    canvas.drawRect(const Rect.fromLTWH(170, 110, 40, 75), fgPaint);

    // Toit du clocher.
    canvas.drawPath(
      Path()
        ..moveTo(165, 110)
        ..lineTo(215, 110)
        ..lineTo(190, 75)
        ..close(),
      fgPaint,
    );

    // Croix.
    canvas.drawRect(const Rect.fromLTWH(186, 50, 8, 28), fgPaint);
    canvas.drawRect(const Rect.fromLTWH(176, 58, 28, 8), fgPaint);

    // Porte (en négatif, couleur de fond).
    canvas.drawRect(const Rect.fromLTWH(175, 270, 30, 40), bgPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EcclesiaIconPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.foregroundColor != foregroundColor;
  }
}

/// Logo complet (icône + nom) — pour écran de démarrage et écrans
/// "à propos". `fontFamily` non précisé : utilise la police système par
/// défaut pour l'instant ; la charte de l'Étape 2 prévoit Oswald pour ce
/// wordmark, à câbler via `google_fonts` ou une police embarquée en local.
class EcclesiaLogoFull extends StatelessWidget {
  final double iconSize;

  const EcclesiaLogoFull({super.key, this.iconSize = 96});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EcclesiaIcon(size: iconSize),
        SizedBox(height: iconSize * 0.12),
        Text(
          'Ecclesia',
          style: TextStyle(
            fontSize: iconSize * 0.28,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: const Color(0xFFE4002B),
          ),
        ),
      ],
    );
  }
}
