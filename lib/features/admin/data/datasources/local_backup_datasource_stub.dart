import '../../../../core/database/database.dart';

class LocalBackupDataSource {
  final AppDatabase db;

  LocalBackupDataSource({required this.db});

  Future<String> exportBackup() async =>
      throw UnsupportedError('Plateforme non prise en charge.');

  Future<void> importBackup(String sourcePath) async =>
      throw UnsupportedError('Plateforme non prise en charge.');

  Future<List<String>> listBackups() async => [];
}
