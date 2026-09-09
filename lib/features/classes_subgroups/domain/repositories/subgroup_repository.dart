import '../../../../core/utils/result.dart';
import '../entities/subgroup.dart';

abstract class SubgroupRepository {
  Future<Result<Subgroup>> createSubgroup(Subgroup subgroup);

  Future<Result<Subgroup>> getSubgroupById(String id);

  Future<Result<List<Subgroup>>> getAllSubgroups({required String churchId});

  /// Rattache un membre à un sous-groupe, avec un rôle ('membre' ou
  /// 'responsable'). Un membre peut appartenir à plusieurs sous-groupes
  /// simultanément (Étape 0, décision #1).
  Future<Result<void>> assignMemberToSubgroup({
    required String memberId,
    required String subgroupId,
    String roleInGroup = 'membre',
  });

  Future<Result<void>> removeMemberFromSubgroup({
    required String memberId,
    required String subgroupId,
  });

  Future<Result<List<String>>> getSubgroupIdsForMember(String memberId);

  Future<Result<List<String>>> getMemberIdsForSubgroup(String subgroupId);
}
