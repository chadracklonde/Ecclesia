import '../../members/domain/entities/member.dart';

Member? findMemberByMatricule(List<Member> members, String matricule) {
  for (final member in members) {
    if (member.matricule == matricule) {
      return member;
    }
  }
  return null;
}
