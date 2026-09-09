import 'package:ecclesia/core/utils/result.dart';
import 'package:ecclesia/features/classes_subgroups/domain/entities/subgroup.dart';
import 'package:ecclesia/features/classes_subgroups/domain/repositories/subgroup_repository.dart';
import 'package:ecclesia/features/classes_subgroups/domain/usecases/assign_member_to_subgroup.dart';
import 'package:ecclesia/features/members/domain/entities/member.dart';
import 'package:ecclesia/features/members/domain/repositories/member_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSubgroupRepository extends Mock implements SubgroupRepository {}

class MockMemberRepository extends Mock implements MemberRepository {}

void main() {
  late MockSubgroupRepository subgroupRepository;
  late MockMemberRepository memberRepository;
  late AssignMemberToSubgroup assignMemberToSubgroup;

  final member = Member(
    id: 'member-1',
    churchId: 'church-1',
    matricule: 'RTC-2026-0001',
    firstName: 'Jeanne',
    lastName: 'Mukendi',
    sex: Sex.female,
    status: MemberStatus.probation,
    statusSince: DateTime(2026),
    joinDate: DateTime(2026),
  );

  const subgroup = Subgroup(
    id: 'sg-1',
    churchId: 'church-1',
    name: 'Chorale',
    type: 'chorale',
  );

  setUp(() {
    subgroupRepository = MockSubgroupRepository();
    memberRepository = MockMemberRepository();
    assignMemberToSubgroup = AssignMemberToSubgroup(
      subgroupRepository: subgroupRepository,
      memberRepository: memberRepository,
    );
  });

  group('AssignMemberToSubgroup', () {
    test('rejette un rôle invalide sans consulter les repositories', () async {
      final result = await assignMemberToSubgroup(
        memberId: 'member-1',
        subgroupId: 'sg-1',
        roleInGroup: 'chef-suprême',
      );

      expect(result, isA<Error<void>>());
      verifyZeroInteractions(memberRepository);
      verifyZeroInteractions(subgroupRepository);
    });

    test('délègue au repository avec le rôle "responsable"', () async {
      when(() => memberRepository.getMemberById('member-1'))
          .thenAnswer((_) async => Success(member));
      when(() => subgroupRepository.getSubgroupById('sg-1'))
          .thenAnswer((_) async => const Success(subgroup));
      when(() => subgroupRepository.assignMemberToSubgroup(
            memberId: 'member-1',
            subgroupId: 'sg-1',
            roleInGroup: 'responsable',
          )).thenAnswer((_) async => const Success(null));

      final result = await assignMemberToSubgroup(
        memberId: 'member-1',
        subgroupId: 'sg-1',
        roleInGroup: 'responsable',
      );

      expect(result, isA<Success<void>>());
      verify(() => subgroupRepository.assignMemberToSubgroup(
            memberId: 'member-1',
            subgroupId: 'sg-1',
            roleInGroup: 'responsable',
          )).called(1);
    });
  });
}
