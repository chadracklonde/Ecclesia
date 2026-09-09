import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../members/domain/entities/member.dart';
import '../../../members/domain/repositories/member_repository.dart';
import '../entities/church_class.dart';
import '../repositories/church_class_repository.dart';

/// Valide l'intégrité multi-tenant (membre et classe de la même église)
/// avant de déléguer au repository. Cette vérification n'était pas dans
/// le dictionnaire de l'Étape 0 mais découle directement du `church_id`
/// posé sur chaque entité — sans elle, rien n'empêcherait de rattacher un
/// membre d'une église à la classe d'une autre.
class AssignMemberToClass {
  final ChurchClassRepository classRepository;
  final MemberRepository memberRepository;

  AssignMemberToClass({
    required this.classRepository,
    required this.memberRepository,
  });

  Future<Result<void>> call({
    required String memberId,
    required String classId,
  }) async {
    final memberResult = await memberRepository.getMemberById(memberId);
    if (memberResult is Error<Member>) {
      return Error(memberResult.failure);
    }
    final member = (memberResult as Success<Member>).value;

    final classResult = await classRepository.getClassById(classId);
    if (classResult is Error<ChurchClass>) {
      return Error(classResult.failure);
    }
    final churchClass = (classResult as Success<ChurchClass>).value;

    if (member.churchId != churchClass.churchId) {
      return const Error(ValidationFailure(
          'Le membre et la classe doivent appartenir à la même église'));
    }

    return classRepository.assignMemberToClass(
      memberId: memberId,
      classId: classId,
    );
  }
}
