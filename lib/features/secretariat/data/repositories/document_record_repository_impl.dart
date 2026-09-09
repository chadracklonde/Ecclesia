import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/document_record.dart';
import '../../domain/repositories/document_record_repository.dart';
import '../datasources/local_document_record_datasource.dart';
import '../models/secretariat_model.dart';

class DocumentRecordRepositoryImpl implements DocumentRecordRepository {
  final LocalDocumentRecordDataSource dataSource;

  DocumentRecordRepositoryImpl(this.dataSource);

  @override
  Future<Result<DocumentRecord>> createDocumentRecord(
    DocumentRecord record,
  ) async {
    try {
      await dataSource.insert(record.toCompanion());
      return Success(record);
    } catch (e) {
      return Error(
          DatabaseFailure('Échec de l\'enregistrement du document : $e'));
    }
  }

  @override
  Future<Result<List<DocumentRecord>>> getDocumentsForChurch({
    required String churchId,
  }) async {
    try {
      final rows = await dataSource.getForChurch(churchId);
      return Success(rows.map((r) => r.toDomain()).toList());
    } catch (e) {
      return Error(DatabaseFailure('Échec de la lecture des documents : $e'));
    }
  }
}
