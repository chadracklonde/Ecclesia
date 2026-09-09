import 'package:ecclesia/core/utils/result.dart';
import 'package:ecclesia/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:ecclesia/features/attendance/domain/usecases/get_members_to_visit.dart';
import 'package:ecclesia/features/members/domain/entities/member.dart';
import 'package:ecclesia/features/members/domain/repositories/member_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMemberRepository extends Mock implements MemberRepository {}

class MockAttendanceRepository extends Mock implements AttendanceRepository {}

void main() {
  late MockMemberRepository memberRepository;
  late MockAttendanceRepository attendanceRepository;
  late GetMembersToVisit getMembersToVisit;

  const churchId = 'church-1';

  Member buildMember(String id) => Member(
        id: id,
        churchId: churchId,
        matricule: 'RTC-2026-000$id',
        firstName: 'Membre',
        lastName: id,
        sex: Sex.female,
        status: MemberStatus.probation,
        statusSince: DateTime(2026),
        joinDate: DateTime(2026),
      );

  setUp(() {
    memberRepository = MockMemberRepository();
    attendanceRepository = MockAttendanceRepository();
    getMembersToVisit = GetMembersToVisit(
      memberRepository: memberRepository,
      attendanceRepository: attendanceRepository,
    );
  });

  test(
      'ne retourne que les membres sans pointage "présent" depuis la date donnée',
      () async {
    final m1 = buildMember('1'); // vu récemment
    final m2 = buildMember('2'); // pas vu depuis longtemps -> à visiter

    when(() => memberRepository.getAllMembers(churchId: churchId))
        .thenAnswer((_) async => Success([m1, m2]));
    when(() => attendanceRepository.getMemberIdsPresentSince(
          churchId: churchId,
          sinceDate: any(named: 'sinceDate'),
        )).thenAnswer((_) async => const Success(['1']));

    final result = await getMembersToVisit(
      churchId: churchId,
      sinceDate: DateTime(2026, 8, 1),
    );

    result.fold(
      (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
      (toVisit) {
        expect(toVisit.length, 1);
        expect(toVisit.first.id, '2');
      },
    );
  });
}
