import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/database/database.dart';

/// `resolveAppDocumentsDir` est injectable : en production, résout le
/// vrai répertoire via `path_provider` (valeur par défaut) ; dans les
/// tests, on passe un répertoire temporaire — pas besoin de mocker de
/// plugin de plateforme.
class LocalBackupDataSource {
  final AppDatabase db;
  final Future<Directory> Function() resolveAppDocumentsDir;

  LocalBackupDataSource({
    required this.db,
    Future<Directory> Function()? resolveAppDocumentsDir,
  }) : resolveAppDocumentsDir =
            resolveAppDocumentsDir ?? getApplicationDocumentsDirectory;

  Future<File> _dbFile() async {
    final dir = await resolveAppDocumentsDir();
    return File(p.join(dir.path, 'ecclesia.sqlite'));
  }

  Future<Directory> _backupsDir() async {
    final dir = await resolveAppDocumentsDir();
    final backups = Directory(p.join(dir.path, 'backups'));
    if (!await backups.exists()) {
      await backups.create(recursive: true);
    }
    return backups;
  }

  /// LIMITE DOCUMENTÉE : `PRAGMA wal_checkpoint(FULL)` réduit mais
  /// n'élimine pas complètement le risque d'incohérence si SQLite est en
  /// mode WAL — une garantie totale exigerait de fermer la connexion
  /// avant la copie, ce qui casserait l'usage pendant l'export. Compromis
  /// acceptable pour une sauvegarde manuelle occasionnelle.
  Future<String> exportBackup() async {
    await db.customStatement('PRAGMA wal_checkpoint(FULL);');

    final dbFile = await _dbFile();
    final backupsDir = await _backupsDir();
    final timestamp =
        DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
    final backupFile =
        File(p.join(backupsDir.path, 'ecclesia-backup-$timestamp.sqlite'));
    await dbFile.copy(backupFile.path);
    return backupFile.path;
  }

  Future<void> importBackup(String sourcePath) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw StateError('Fichier de sauvegarde introuvable : $sourcePath');
    }
    final dbFile = await _dbFile();
    await sourceFile.copy(dbFile.path);
  }

  Future<List<String>> listBackups() async {
    final backupsDir = await _backupsDir();
    final entries = await backupsDir.list().toList();
    final paths = entries.whereType<File>().map((f) => f.path).toList();
    paths.sort();
    return paths;
  }
}
