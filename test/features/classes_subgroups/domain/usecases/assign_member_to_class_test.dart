import 'package:ecclesia/core/errors/failures.dart';
import 'package:ecclesia/core/utils/result.dart';
import 'package:ecclesia/features/classes_subgroups/domain/entities/church_class.dart';
import 'package:ecclesia/features/classes_subgroups/domain/repositories/church_class_repository.dart';
import 'package:ecclesia/features/classes_subgroups/domain/usecases/assign_member_to_class.dart';
import 'package:ecclesia/features/members/domain/entities/member.dart';
import 'package:ecclesia/features/members/domain/repositories/member_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChurchClassRepository extends Mock implements ChurchClassRepository {}

class MockMemberRepository extends Mock implements MemberRepository {}

void main() {
  late MockChurchClassRepository classRepository;
  late MockMemberRepository memberRepository;
  late AssignMemberToClass assignMemberToClass;

  Member buildMember({required String churchId}) => Member(
        id: 'member-1',
        churchId: churchId,
        matricule: 'RTC-2026-0001',
        firstName: 'Jeanne',
        lastName: 'Mukendi',
        sex: Sex.female,
        status: MemberStatus.probation,
        statusSince: DateTime(2026),
        joinDate: DateTime(2026),
      );

  ChurchClass buildClass({required String churchId}) => ChurchClass(
        id: 'class-1',
        churchId: churchId,
        name: 'Classe Emmanuel',
      );

  setUp(() {
    classRepository = MockChurchClassRepository();
    memberRepository = MockMemberRepository();
    assignMemberToClass = AssignMemberToClass(
      classRepository: classRepository,
      memberRepository: memberRepository,
    );
  });

  group('AssignMemberToClass', () {
    test('délègue au repository quand membre et classe partagent l\'église',
        () async {
      when(() => memberRepository.getMemberById('member-1'))
          .thenAnswer((_) async => Success(buildMember(churchId: 'church-1')));
      when(() => classRepository.getClassById('class-1'))
          .thenAnswer((_) async => Success(buildClass(churchId: 'church-1')));
      when(() => classRepository.assignMemberToClass(
            memberId: 'member-1',
            classId: 'class-1',
          )).thenAnswer((_) async => const Success(null));

      final result = await assignMemberToClass(
        memberId: 'member-1',
        classId: 'class-1',
      );

      expect(result, isA<Success<void>>());
      verify(() => classRepository.assignMemberToClass(
            memberId: 'member-1',
            classId: 'class-1',
          )).called(1);
    });

    test(
        'rejette le rattachement si le membre et la classe sont d\'églises différentes',
        () async {
      when(() => memberRepository.getMemberById('member-1'))
          .thenAnswer((_) async => Success(buildMember(churchId: 'church-1')));
      when(() => classRepository.getClassById('class-1')).thenAnswer(
          (_) async => Success(buildClass(churchId: 'church-AUTRE')));

      final result = await assignMemberToClass(
        memberId: 'member-1',
        classId: 'class-1',
      );

      expect(result, isA<Error<void>>());
      verifyNever(() => classRepository.assignMemberToClass(
            memberId: any(named: 'memberId'),
            classId: any(named: 'classId'),
          ));
    });

    test(
        'propage l\'échec si le membre est introuvable sans appeler classRepository',
        () async {
      when(() => memberRepository.getMemberById('inconnu')).thenAnswer(
          (_) async => const Error(NotFoundFailure('membre introuvable')));

      final result = await assignMemberToClass(
        memberId: 'inconnu',
        classId: 'class-1',
      );

      expect(result, isA<Error<void>>());
      verifyNever(() => classRepository.getClassById(any()));
    });
  });
}
