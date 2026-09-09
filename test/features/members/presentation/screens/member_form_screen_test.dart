import 'package:ecclesia/features/members/presentation/screens/member_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('affiche une erreur de validation si le prénom est vide',
      (tester) async {
    // Pas de ProviderScope.overrides ici : la validation du formulaire
    // bloque avant tout `ref.read(createMemberProvider)`, donc aucun accès
    // à la base de données réelle n'est déclenché par ce test.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: MemberFormScreen(churchId: 'church-1')),
      ),
    );

    await tester.tap(find.text('Créer le membre'));
    await tester.pump();

    expect(find.text('Le prénom est obligatoire'), findsOneWidget);
  });
}
