import '../../../../core/utils/result.dart';
import '../entities/document_record.dart';
import '../repositories/document_record_repository.dart';

class ListDocuments {
  final DocumentRecordRepository repository;

  ListDocuments(this.repository);

  Future<Result<List<DocumentRecord>>> call({required String churchId}) {
    return repository.getDocumentsForChurch(churchId: churchId);
  }
}
