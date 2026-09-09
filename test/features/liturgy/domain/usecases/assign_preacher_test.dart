import 'package:ecclesia/core/utils/result.dart';
import 'package:ecclesia/features/liturgy/domain/entities/preacher_assignment.dart';
import 'package:ecclesia/features/liturgy/domain/entities/service.dart';
import 'package:ecclesia/features/liturgy/domain/repositories/preacher_assignment_repository.dart';
import 'package:ecclesia/features/liturgy/domain/repositories/service_repository.dart';
import 'package:ecclesia/features/liturgy/domain/usecases/assign_preacher.dart';
import 'package:ecclesia/features/members/domain/entities/member.dart';
import 'package:ecclesia/features/members/domain/repositories/member_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockServiceRepository extends Mock implements ServiceRepository {}

class MockPreacherAssignmentRepository extends Mock
    implements PreacherAssignmentRepository {}

class MockMemberRepository extends Mock implements MemberRepository {}

void main() {
  late MockServiceRepository serviceRepository;
  late MockPreacherAssignmentRepository assignmentRepository;
  late MockMemberRepository memberRepository;
  late AssignPreacher assignPreacher;

  const churchId = 'church-1';
  final sameDay = DateTime(2026, 9, 13, 10);

  final serviceA = Service(
      id: 'service-A', churchId: churchId, date: sameDay, type: ServiceType.dominical);
  final serviceB = Service(
      id: 'service-B',
      churchId: churchId,
      date: DateTime(2026, 9, 13, 18),
      type: ServiceType.veillee);

  final member = Member(
    id: 'member-1',
    churchId: churchId,
    matricule: 'RTC-2026-0001',
    firstName: 'Paul',
    lastName: 'Ilunga',
    sex: Sex.male,
    status: MemberStatus.fullMember,
    statusSince: DateTime(2026),
    joinDate: DateTime(2026),
  );

  setUp(() {
    serviceRepository = MockServiceRepository();
    assignmentRepository = MockPreacherAssignmentRepository();
    memberRepository = MockMemberRepository();
    assignPreacher = AssignPreacher(
      assignmentRepository: assignmentRepository,
      serviceRepository: serviceRepository,
      memberRepository: memberRepository,
    );
  });

  group('AssignPreacher', () {
    test('rejette si ni membre ni nom externe ne sont fournis', () async {
      final result = await assignPreacher(serviceId: 'service-A');
      expect(result, isA<Error<PreacherAssignment>>());
      verifyNever(() => serviceRepository.getServiceById(any()));
    });

    test('accepte un prédicateur externe sans vérification de membre',
        () async {
      when(() => serviceRepository.getServiceById('service-A'))
          .thenAnswer((_) async => Success(serviceA));
      when(() => assignmentRepository.assignPreacher(any()))
          .thenAnswer((invocation) async =>
              Success(invocation.positionalArguments.first as PreacherAssignment));

      final result = await assignPreacher(
        serviceId: 'service-A',
        externalName: 'Rév. Kalonji',
      );

      expect(result, isA<Success<PreacherAssignment>>());
      verifyNever(() => memberRepository.getMemberById(any()));
    });

    test(
        'détecte un conflit : le membre est déjà prédicateur d\'un autre culte le même jour',
        () async {
      when(() => serviceRepository.getServiceById('service-B'))
          .thenAnswer((_) async => Success(serviceB));
      when(() => memberRepository.getMemberById('member-1'))
          .thenAnswer((_) async => Success(member));
      when(() => serviceRepository.getServicesForChurch(
            churchId: churchId,
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).thenAnswer((_) async => Success([serviceA, serviceB]));
      when(() => assignmentRepository.getAssignmentsForService('service-A'))
          .thenAnswer((_) async => Success([
                const PreacherAssignment(
                  id: 'assign-existing',
                  serviceId: 'service-A',
                  memberId: 'member-1',
                ),
              ]));

      final result = await assignPreacher(
        serviceId: 'service-B',
        memberId: 'member-1',
      );

      expect(result, isA<Error<PreacherAssignment>>());
      verifyNever(() => assignmentRepository.assignPreacher(any()));
    });

    test('aucun conflit : le membre n\'est prédicateur d\'aucun autre culte le même jour',
        () async {
      when(() => serviceRepository.getServiceById('service-B'))
          .thenAnswer((_) async => Success(serviceB));
      when(() => memberRepository.getMemberById('member-1'))
          .thenAnswer((_) async => Success(member));
      when(() => serviceRepository.getServicesForChurch(
            churchId: churchId,
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).thenAnswer((_) async => Success([serviceA, serviceB]));
      when(() => assignmentRepository.getAssignmentsForService('service-A'))
          .thenAnswer((_) async => const Success([])); // personne d'affecté
      when(() => assignmentRepository.assignPreacher(any()))
          .thenAnswer((invocation) async =>
              Success(invocation.positionalArguments.first as PreacherAssignment));

      final result = await assignPreacher(
        serviceId: 'service-B',
        memberId: 'member-1',
      );

      expect(result, isA<Success<PreacherAssignment>>());
    });
  });
}
