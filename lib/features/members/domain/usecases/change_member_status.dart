import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/member.dart';
import '../repositories/member_repository.dart';

/// Valide qu'une transition de statut a un sens avant de déléguer au
/// repository (qui, lui, trace l'historique de façon atomique —
/// Étape 0 décision #4). Le usecase ne réécrit pas cette logique
/// d'historisation, il ajoute uniquement la validation métier.
class ChangeMemberStatus {
  final MemberRepository repository;

  ChangeMemberStatus(this.repository);

  Future<Result<Member>> call({
    required String memberId,
    required MemberStatus newStatus,
    String? note,
    String? recordedBy,
  }) async {
    final currentResult = await repository.getMemberById(memberId);
    if (currentResult is Error<Member>) {
      return currentResult;
    }
    final current = (currentResult as Success<Member>).value;

    if (current.status == newStatus) {
      return const Error(ValidationFailure(
          'Le nouveau statut doit être différent du statut actuel'));
    }

    return repository.updateMemberStatus(
      memberId: memberId,
      newStatus: newStatus,
      note: note,
      recordedBy: recordedBy,
    );
  }
}
