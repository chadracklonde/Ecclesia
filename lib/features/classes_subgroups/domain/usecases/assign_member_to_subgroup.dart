import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../members/domain/entities/member.dart';
import '../../../members/domain/repositories/member_repository.dart';
import '../entities/subgroup.dart';
import '../repositories/subgroup_repository.dart';

const _validRoles = ['membre', 'responsable'];

class AssignMemberToSubgroup {
  final SubgroupRepository subgroupRepository;
  final MemberRepository memberRepository;

  AssignMemberToSubgroup({
    required this.subgroupRepository,
    required this.memberRepository,
  });

  Future<Result<void>> call({
    required String memberId,
    required String subgroupId,
    String roleInGroup = 'membre',
  }) async {
    if (!_validRoles.contains(roleInGroup)) {
      return Error(ValidationFailure(
          'Rôle invalide : $roleInGroup (attendu : ${_validRoles.join(' ou ')})'));
    }

    final memberResult = await memberRepository.getMemberById(memberId);
    if (memberResult is Error<Member>) {
      return Error(memberResult.failure);
    }
    final member = (memberResult as Success<Member>).value;

    final subgroupResult = await subgroupRepository.getSubgroupById(subgroupId);
    if (subgroupResult is Error<Subgroup>) {
      return Error(subgroupResult.failure);
    }
    final subgroup = (subgroupResult as Success<Subgroup>).value;

    if (member.churchId != subgroup.churchId) {
      return const Error(ValidationFailure(
          'Le membre et le sous-groupe doivent appartenir à la même église'));
    }

    return subgroupRepository.assignMemberToSubgroup(
      memberId: memberId,
      subgroupId: subgroupId,
      roleInGroup: roleInGroup,
    );
  }
}
