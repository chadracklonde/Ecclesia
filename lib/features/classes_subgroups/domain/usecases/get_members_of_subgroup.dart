import '../../../../core/utils/result.dart';
import '../../../members/domain/entities/member.dart';
import '../../../members/domain/repositories/member_repository.dart';
import '../repositories/subgroup_repository.dart';

class GetMembersOfSubgroup {
  final SubgroupRepository subgroupRepository;
  final MemberRepository memberRepository;

  GetMembersOfSubgroup({
    required this.subgroupRepository,
    required this.memberRepository,
  });

  Future<Result<List<Member>>> call(String subgroupId) async {
    final idsResult =
        await subgroupRepository.getMemberIdsForSubgroup(subgroupId);
    if (idsResult is Error<List<String>>) {
      return Error(idsResult.failure);
    }
    final ids = (idsResult as Success<List<String>>).value;

    final members = <Member>[];
    for (final id in ids) {
      final memberResult = await memberRepository.getMemberById(id);
      if (memberResult is Success<Member>) {
        members.add(memberResult.value);
      }
    }
    return Success(members);
  }
}
