import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/member.dart';
import '../../domain/repositories/member_repository.dart';
import '../datasources/local_member_datasource.dart';
import '../models/member_model.dart';

class MemberRepositoryImpl implements MemberRepository {
  final LocalMemberDataSource dataSource;

  MemberRepositoryImpl(this.dataSource);

  @override
  Future<Result<Member>> createMember(Member member) async {
    try {
      await dataSource.insertMember(member.toCompanion());
      return Success(member);
    } catch (e) {
      return Error(DatabaseFailure('Échec de la création du membre : $e'));
    }
  }

  @override
  Future<Result<Member>> getMemberById(String id) async {
    try {
      final row = await dataSource.getMemberById(id);
      if (row == null) {
        return const Error(NotFoundFailure('Membre introuvable'));
      }
      return Success(row.toDomain());
    } catch (e) {
      return Error(DatabaseFailure('Échec de la lecture du membre : $e'));
    }
  }

  @override
  Future<Result<List<Member>>> getAllMembers({
    required String churchId,
  }) async {
    try {
      final rows = await dataSource.getAllMembersByChurch(churchId);
      return Success(rows.map((r) => r.toDomain()).toList());
    } catch (e) {
      return Error(DatabaseFailure('Échec de la lecture des membres : $e'));
    }
  }

  @override
  Future<Result<Member>> updateMemberStatus({
    required String memberId,
    required MemberStatus newStatus,
    String? note,
    String? recordedBy,
  }) async {
    try {
      final current = await dataSource.getMemberById(memberId);
      if (current == null) {
        return const Error(NotFoundFailure('Membre introuvable'));
      }
      final updated = await dataSource.updateStatusWithHistory(
        memberId: memberId,
        oldStatus: current.status,
        newStatus:
            newStatus == MemberStatus.fullMember ? 'full_member' : 'probation',
        changeDate: DateTime.now(),
        note: note,
        recordedBy: recordedBy,
        historyId: const Uuid().v4(),
      );
      return Success(updated.toDomain());
    } catch (e) {
      return Error(DatabaseFailure('Échec de la mise à jour du statut : $e'));
    }
  }
}
