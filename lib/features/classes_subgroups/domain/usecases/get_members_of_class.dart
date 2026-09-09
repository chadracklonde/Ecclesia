import '../../../../core/utils/result.dart';
import '../../../members/domain/entities/member.dart';
import '../../../members/domain/repositories/member_repository.dart';
import '../repositories/church_class_repository.dart';

class GetMembersOfClass {
  final ChurchClassRepository classRepository;
  final MemberRepository memberRepository;

  GetMembersOfClass({
    required this.classRepository,
    required this.memberRepository,
  });

  Future<Result<List<Member>>> call(String classId) async {
    final idsResult = await classRepository.getMemberIdsForClass(classId);
    if (idsResult is Error<List<String>>) {
      return Error(idsResult.failure);
    }
    final ids = (idsResult as Success<List<String>>).value;

    final members = <Member>[];
    for (final id in ids) {
      final memberResult = await memberRepository.getMemberById(id);
      // Un membre introuvable (supprimé entre-temps) est ignoré plutôt
      // que de faire échouer tout l'affichage de la classe.
      if (memberResult is Success<Member>) {
        members.add(memberResult.value);
      }
    }
    return Success(members);
  }
}
