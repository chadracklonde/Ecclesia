import '../../../../core/utils/result.dart';
import '../entities/member.dart';

/// Interface abstraite — la couche présentation et les usecases ne
/// dépendent jamais de `drift` directement, seulement de ce contrat
/// (règle stricte actée à l'Étape 1).
abstract class MemberRepository {
  /// Crée un membre. L'appelant (usecase) est responsable de générer
  /// `id` (UUID) et `matricule` avant d'appeler cette méthode — la
  /// couche data ne prend aucune décision métier.
  Future<Result<Member>> createMember(Member member);

  Future<Result<Member>> getMemberById(String id);

  Future<Result<List<Member>>> getAllMembers({required String churchId});

  /// Change le statut d'un membre ET insère une ligne dans l'historique,
  /// de façon atomique (Étape 0, décision #4 : traçabilité intégrale,
  /// jamais d'écrasement silencieux du statut précédent).
  Future<Result<Member>> updateMemberStatus({
    required String memberId,
    required MemberStatus newStatus,
    String? note,
    String? recordedBy,
  });
}
