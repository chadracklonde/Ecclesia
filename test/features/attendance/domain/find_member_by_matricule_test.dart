import 'package:ecclesia/features/attendance/domain/find_member_by_matricule.dart';
import 'package:ecclesia/features/members/domain/entities/member.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final members = [
    Member(
      id: 'm1',
      churchId: 'church-1',
      matricule: 'RTC-2026-0001',
      firstName: 'Jeanne',
      lastName: 'Mukendi',
      sex: Sex.female,
      status: MemberStatus.probation,
      statusSince: DateTime(2026),
      joinDate: DateTime(2026),
    ),
  ];

  test('retrouve le membre correspondant au matricule scanné', () {
    final found = findMemberByMatricule(members, 'RTC-2026-0001');
    expect(found?.id, 'm1');
  });

  test('retourne null si aucun membre ne correspond', () {
    final found = findMemberByMatricule(members, 'INCONNU');
    expect(found, isNull);
  });
}
