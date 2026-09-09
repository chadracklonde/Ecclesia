import 'package:ecclesia/features/classes_subgroups/presentation/screens/class_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('affiche une erreur de validation si le nom est vide',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ClassFormScreen(churchId: 'church-1')),
      ),
    );

    await tester.tap(find.text('Créer la classe'));
    await tester.pump();

    expect(find.text('Le nom est obligatoire'), findsOneWidget);
  });
}
