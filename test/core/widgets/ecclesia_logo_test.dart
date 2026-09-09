import 'package:ecclesia/core/widgets/ecclesia_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EcclesiaIcon se construit sans erreur', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: EcclesiaIcon())),
    );
    expect(find.byType(EcclesiaIcon), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('EcclesiaLogoFull affiche l\'icône et le nom', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: EcclesiaLogoFull())),
    );
    expect(find.byType(EcclesiaIcon), findsOneWidget);
    expect(find.text('Ecclesia'), findsOneWidget);
  });
}
