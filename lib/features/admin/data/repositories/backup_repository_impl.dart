import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/backup_repository.dart';
import '../datasources/local_backup_datasource.dart';

class BackupRepositoryImpl implements BackupRepository {
  final LocalBackupDataSource dataSource;

  BackupRepositoryImpl(this.dataSource);

  @override
  Future<Result<String>> exportBackup() async {
    try {
      final path = await dataSource.exportBackup();
      return Success(path);
    } catch (e) {
      return Error(DatabaseFailure('Échec de l\'export de la sauvegarde : $e'));
    }
  }

  @override
  Future<Result<void>> importBackup(String sourcePath) async {
    try {
      await dataSource.importBackup(sourcePath);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Échec de l\'import de la sauvegarde : $e'));
    }
  }

  @override
  Future<Result<List<String>>> listBackups() async {
    try {
      return Success(await dataSource.listBackups());
    } catch (e) {
      return Error(DatabaseFailure('Échec de la lecture des sauvegardes : $e'));
    }
  }
}
