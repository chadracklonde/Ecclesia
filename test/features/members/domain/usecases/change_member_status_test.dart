import 'package:ecclesia/core/errors/failures.dart';
import 'package:ecclesia/core/utils/result.dart';
import 'package:ecclesia/features/members/domain/entities/member.dart';
import 'package:ecclesia/features/members/domain/repositories/member_repository.dart';
import 'package:ecclesia/features/members/domain/usecases/change_member_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMemberRepository extends Mock implements MemberRepository {}

void main() {
  late MockMemberRepository repository;
  late ChangeMemberStatus changeMemberStatus;

  final baseMember = Member(
    id: 'member-1',
    churchId: 'church-1',
    matricule: 'RTC-2026-0001',
    firstName: 'Jeanne',
    lastName: 'Mukendi',
    sex: Sex.female,
    status: MemberStatus.probation,
    statusSince: DateTime(2026, 1, 1),
    joinDate: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(MemberStatus.probation);
  });

  setUp(() {
    repository = MockMemberRepository();
    changeMemberStatus = ChangeMemberStatus(repository);
  });

  group('ChangeMemberStatus', () {
    test('rejette une transition vers le même statut sans appeler updateMemberStatus',
        () async {
      when(() => repository.getMemberById(baseMember.id))
          .thenAnswer((_) async => Success(baseMember));

      final result = await changeMemberStatus(
        memberId: baseMember.id,
        newStatus: MemberStatus.probation,
      );

      expect(result, isA<Error<Member>>());
      verifyNever(() => repository.updateMemberStatus(
            memberId: any(named: 'memberId'),
            newStatus: any(named: 'newStatus'),
            note: any(named: 'note'),
            recordedBy: any(named: 'recordedBy'),
          ));
    });

    test('propage l\'échec si le membre est introuvable', () async {
      when(() => repository.getMemberById('inconnu'))
          .thenAnswer((_) async => const Error(NotFoundFailure('introuvable')));

      final result = await changeMemberStatus(
        memberId: 'inconnu',
        newStatus: MemberStatus.fullMember,
      );

      expect(result, isA<Error<Member>>());
      verifyNever(() => repository.updateMemberStatus(
            memberId: any(named: 'memberId'),
            newStatus: any(named: 'newStatus'),
            note: any(named: 'note'),
            recordedBy: any(named: 'recordedBy'),
          ));
    });

    test('délègue au repository pour une transition valide', () async {
      when(() => repository.getMemberById(baseMember.id))
          .thenAnswer((_) async => Success(baseMember));
      when(() => repository.updateMemberStatus(
            memberId: baseMember.id,
            newStatus: MemberStatus.fullMember,
            note: 'après catéchisme',
            recordedBy: 'user-1',
          )).thenAnswer(
        (_) async => Success(baseMember.copyWith(status: MemberStatus.fullMember)),
      );

      final result = await changeMemberStatus(
        memberId: baseMember.id,
        newStatus: MemberStatus.fullMember,
        note: 'après catéchisme',
        recordedBy: 'user-1',
      );

      expect(result, isA<Success<Member>>());
      final updated = (result as Success<Member>).value;
      expect(updated.status, MemberStatus.fullMember);
    });
  });
}
