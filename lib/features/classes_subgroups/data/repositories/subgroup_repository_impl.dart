import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/subgroup.dart';
import '../../domain/repositories/subgroup_repository.dart';
import '../datasources/local_subgroup_datasource.dart';
import '../models/community_models.dart';

class SubgroupRepositoryImpl implements SubgroupRepository {
  final LocalSubgroupDataSource dataSource;

  SubgroupRepositoryImpl(this.dataSource);

  @override
  Future<Result<Subgroup>> createSubgroup(Subgroup subgroup) async {
    try {
      await dataSource.insertSubgroup(subgroup.toCompanion());
      return Success(subgroup);
    } catch (e) {
      return Error(DatabaseFailure('Échec de la création du sous-groupe : $e'));
    }
  }

  @override
  Future<Result<Subgroup>> getSubgroupById(String id) async {
    try {
      final row = await dataSource.getSubgroupById(id);
      if (row == null) {
        return const Error(NotFoundFailure('Sous-groupe introuvable'));
      }
      return Success(row.toDomain());
    } catch (e) {
      return Error(DatabaseFailure('Échec de la lecture du sous-groupe : $e'));
    }
  }

  @override
  Future<Result<List<Subgroup>>> getAllSubgroups({
    required String churchId,
  }) async {
    try {
      final rows = await dataSource.getAllSubgroups(churchId);
      return Success(rows.map((r) => r.toDomain()).toList());
    } catch (e) {
      return Error(DatabaseFailure('Échec de la lecture des sous-groupes : $e'));
    }
  }

  @override
  Future<Result<void>> assignMemberToSubgroup({
    required String memberId,
    required String subgroupId,
    String roleInGroup = 'membre',
  }) async {
    try {
      await dataSource.assignMember(
        memberId: memberId,
        subgroupId: subgroupId,
        roleInGroup: roleInGroup,
      );
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Échec du rattachement au sous-groupe : $e'));
    }
  }

  @override
  Future<Result<void>> removeMemberFromSubgroup({
    required String memberId,
    required String subgroupId,
  }) async {
    try {
      await dataSource.removeMember(memberId: memberId, subgroupId: subgroupId);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Échec du retrait du sous-groupe : $e'));
    }
  }

  @override
  Future<Result<List<String>>> getSubgroupIdsForMember(String memberId) async {
    try {
      return Success(await dataSource.getSubgroupIdsForMember(memberId));
    } catch (e) {
      return Error(
          DatabaseFailure('Échec de la lecture des sous-groupes du membre : $e'));
    }
  }

  @override
  Future<Result<List<String>>> getMemberIdsForSubgroup(String subgroupId) async {
    try {
      return Success(await dataSource.getMemberIdsForSubgroup(subgroupId));
    } catch (e) {
      return Error(
          DatabaseFailure('Échec de la lecture des membres du sous-groupe : $e'));
    }
  }
}
