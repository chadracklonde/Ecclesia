import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/preacher_assignment.dart';
import '../../domain/repositories/preacher_assignment_repository.dart';
import '../datasources/local_preacher_assignment_datasource.dart';
import '../models/liturgy_model.dart';

class PreacherAssignmentRepositoryImpl implements PreacherAssignmentRepository {
  final LocalPreacherAssignmentDataSource dataSource;

  PreacherAssignmentRepositoryImpl(this.dataSource);

  @override
  Future<Result<PreacherAssignment>> assignPreacher(
    PreacherAssignment assignment,
  ) async {
    try {
      await dataSource.insert(assignment.toCompanion());
      return Success(assignment);
    } catch (e) {
      return Error(DatabaseFailure('Échec de l\'affectation du prédicateur : $e'));
    }
  }

  @override
  Future<Result<List<PreacherAssignment>>> getAssignmentsForService(
    String serviceId,
  ) async {
    try {
      final rows = await dataSource.getForService(serviceId);
      return Success(rows.map((r) => r.toDomain()).toList());
    } catch (e) {
      return Error(DatabaseFailure('Échec de la lecture des affectations : $e'));
    }
  }

  @override
  Future<Result<void>> removeAssignment(String id) async {
    try {
      await dataSource.remove(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Échec du retrait de l\'affectation : $e'));
    }
  }
}
