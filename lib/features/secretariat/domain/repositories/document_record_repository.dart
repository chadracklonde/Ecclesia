import '../../../../core/utils/result.dart';
import '../entities/document_record.dart';

abstract class DocumentRecordRepository {
  Future<Result<DocumentRecord>> createDocumentRecord(DocumentRecord record);

  Future<Result<List<DocumentRecord>>> getDocumentsForChurch({
    required String churchId,
  });
}
