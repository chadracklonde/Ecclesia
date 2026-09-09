import 'package:ecclesia/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'affiche une grille sur large écran et une liste verticale sur mobile',
      (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen(churchId: 'church-1')),
    );
    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(ListView), findsNothing);

    await tester.binding.setSurfaceSize(const Size(400, 800));
    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen(churchId: 'church-1')),
    );
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(GridView), findsNothing);
  });
}
