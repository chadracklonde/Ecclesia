import '../../../../core/utils/result.dart';
import '../entities/preacher_assignment.dart';

abstract class PreacherAssignmentRepository {
  Future<Result<PreacherAssignment>> assignPreacher(
    PreacherAssignment assignment,
  );

  Future<Result<List<PreacherAssignment>>> getAssignmentsForService(
    String serviceId,
  );

  Future<Result<void>> removeAssignment(String id);
}
