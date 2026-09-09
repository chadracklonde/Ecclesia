import '../../../../core/utils/result.dart';
import '../../../members/domain/entities/member.dart';
import '../../../members/domain/repositories/member_repository.dart';
import '../repositories/attendance_repository.dart';

/// Répond directement au besoin exprimé : identifier les fidèles à
/// visiter/réveiller, pas suivre un calendrier liturgique. Un membre
/// "à visiter" est un membre actif qui n'a aucun pointage "présent"
/// depuis `sinceDate`.
class GetMembersToVisit {
  final MemberRepository memberRepository;
  final AttendanceRepository attendanceRepository;

  GetMembersToVisit({
    required this.memberRepository,
    required this.attendanceRepository,
  });

  Future<Result<List<Member>>> call({
    required String churchId,
    required DateTime sinceDate,
  }) async {
    final membersResult = await memberRepository.getAllMembers(churchId: churchId);
    if (membersResult is Error<List<Member>>) {
      return Error(membersResult.failure);
    }
    final members = (membersResult as Success<List<Member>>).value;

    final presentIdsResult = await attendanceRepository.getMemberIdsPresentSince(
      churchId: churchId,
      sinceDate: sinceDate,
    );
    if (presentIdsResult is Error<List<String>>) {
      return Error(presentIdsResult.failure);
    }
    final presentIds = (presentIdsResult as Success<List<String>>).value.toSet();

    final toVisit = members.where((m) => !presentIds.contains(m.id)).toList();
    return Success(toVisit);
  }
}
