import '../../../../core/database/database.dart';

/// Sauvegarde/restauration locale non disponible sur Web pour l'instant
/// (décision actée le 09/09/2026, en même temps que le choix Web
/// hors-ligne via drift/wasm) : il n'y a pas de système de fichiers
/// accessible comme sur mobile/desktop. Une vraie implémentation Web
/// nécessiterait un export/import via téléchargement de fichier dans le
/// navigateur (`dart:html` ou `package:web`), non implémenté ici — pas
/// vérifiable dans ce sandbox. Dégrade proprement (erreur explicite au
/// lieu de planter la compilation Web avec `dart:io`).
class LocalBackupDataSource {
  final AppDatabase db;

  LocalBackupDataSource({required this.db});

  Future<String> exportBackup() async {
    throw UnsupportedError(
        'La sauvegarde locale n\'est pas encore disponible sur Web.');
  }

  Future<void> importBackup(String sourcePath) async {
    throw UnsupportedError(
        'La restauration locale n\'est pas encore disponible sur Web.');
  }

  Future<List<String>> listBackups() async => [];
}
