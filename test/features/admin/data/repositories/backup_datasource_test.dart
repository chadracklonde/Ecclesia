import 'dart:io';

import 'package:drift/native.dart';
import 'package:ecclesia/core/database/database.dart';
import 'package:ecclesia/features/admin/data/datasources/local_backup_datasource.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'export puis import restaure l\'état de la base au moment de la sauvegarde '
      '(en simulant un redémarrage de l\'app)', () async {
    final tempDir = await Directory.systemTemp.createTemp('ecclesia_backup_test_');
    addTearDown(() => tempDir.delete(recursive: true));

    Future<Directory> resolveDir() async => tempDir;

    final dbFile = File(p.join(tempDir.path, 'ecclesia.sqlite'));
    var db = AppDatabase(NativeDatabase(dbFile));
    final dataSource =
        LocalBackupDataSource(db: db, resolveAppDocumentsDir: resolveDir);

    await db.into(db.churches).insert(
        ChurchesCompanion.insert(id: 'church-1', code: 'RTC', name: 'RTC-MALI'));

    final backupPath = await dataSource.exportBackup();
    expect(File(backupPath).existsSync(), isTrue);

    // Modification effectuée APRÈS la sauvegarde : ne doit pas survivre
    // à la restauration.
    await db.into(db.churches).insert(ChurchesCompanion.insert(
        id: 'church-2', code: 'XXX', name: 'Église ajoutée après la sauvegarde'));

    final beforeRestore = await db.select(db.churches).get();
    expect(beforeRestore.length, 2); // les deux existent avant restauration

    // Simule un redémarrage : la connexion doit être fermée avant que le
    // fichier ne soit écrasé (limite documentée dans LocalBackupDataSource).
    await db.close();

    await dataSource.importBackup(backupPath);

    // Nouvelle connexion — comme après un vrai redémarrage de l'app.
    db = AppDatabase(NativeDatabase(dbFile));
    final afterRestore = await db.select(db.churches).get();

    expect(afterRestore.length, 1);
    expect(afterRestore.first.id, 'church-1');

    await db.close();
  });

  test('listBackups retrouve les sauvegardes créées', () async {
    final tempDir = await Directory.systemTemp.createTemp('ecclesia_backup_test_');
    addTearDown(() => tempDir.delete(recursive: true));

    Future<Directory> resolveDir() async => tempDir;
    final dbFile = File(p.join(tempDir.path, 'ecclesia.sqlite'));
    final db = AppDatabase(NativeDatabase(dbFile));
    final dataSource =
        LocalBackupDataSource(db: db, resolveAppDocumentsDir: resolveDir);

    await db.into(db.churches).insert(
        ChurchesCompanion.insert(id: 'church-1', code: 'RTC', name: 'RTC-MALI'));

    await dataSource.exportBackup();
    final backups = await dataSource.listBackups();

    expect(backups.length, 1);
    await db.close();
  });
}
