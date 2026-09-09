import '../../../../core/utils/result.dart';
import '../entities/church_class.dart';

abstract class ChurchClassRepository {
  Future<Result<ChurchClass>> createClass(ChurchClass churchClass);

  Future<Result<ChurchClass>> getClassById(String id);

  Future<Result<List<ChurchClass>>> getAllClasses({required String churchId});

  /// Rattache un membre à une classe. Un membre peut appartenir à
  /// plusieurs classes simultanément (Étape 0, décision #1) — cette
  /// méthode ne retire aucun rattachement existant.
  Future<Result<void>> assignMemberToClass({
    required String memberId,
    required String classId,
  });

  Future<Result<void>> removeMemberFromClass({
    required String memberId,
    required String classId,
  });

  Future<Result<List<String>>> getClassIdsForMember(String memberId);

  Future<Result<List<String>>> getMemberIdsForClass(String classId);
}
