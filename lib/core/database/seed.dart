import 'database.dart';

/// Amorçage minimal pour le mode démonstration : garantit qu'une église
/// existe avant toute création de membre (contrainte de clé étrangère
/// `churchId` sur `Members`).
///
/// À REMPLACER par le véritable écran de création/configuration d'église
/// prévu à l'Étape 9 (Administration) — ceci n'est pas un mécanisme
/// multi-église, juste un bootstrap pour que la PoC soit utilisable sans
/// attendre cette étape.
Future<void> ensureDemoChurch(
  AppDatabase db, {
  required String id,
  required String code,
  required String name,
}) async {
  final existing =
      await (db.select(db.churches)..where((c) => c.id.equals(id)))
          .getSingleOrNull();
  if (existing == null) {
    await db.into(db.churches).insert(
          ChurchesCompanion.insert(id: id, code: code, name: name),
        );
  }
}
