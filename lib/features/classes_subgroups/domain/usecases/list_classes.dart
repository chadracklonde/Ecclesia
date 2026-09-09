import '../../../../core/utils/result.dart';
import '../entities/church_class.dart';
import '../repositories/church_class_repository.dart';

class ListClasses {
  final ChurchClassRepository repository;

  ListClasses(this.repository);

  Future<Result<List<ChurchClass>>> call({required String churchId}) {
    return repository.getAllClasses(churchId: churchId);
  }
}
