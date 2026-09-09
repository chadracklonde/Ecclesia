import '../../../../core/utils/result.dart';
import '../repositories/backup_repository.dart';

class ExportBackup {
  final BackupRepository repository;

  ExportBackup(this.repository);

  Future<Result<String>> call() => repository.exportBackup();
}

class ImportBackup {
  final BackupRepository repository;

  ImportBackup(this.repository);

  Future<Result<void>> call(String sourcePath) =>
      repository.importBackup(sourcePath);
}

class ListBackups {
  final BackupRepository repository;

  ListBackups(this.repository);

  Future<Result<List<String>>> call() => repository.listBackups();
}
