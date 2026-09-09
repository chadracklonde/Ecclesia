import 'package:drift/native.dart';
import 'package:ecclesia/core/database/database.dart';
import 'package:ecclesia/features/liturgy/data/datasources/local_preacher_assignment_datasource.dart';
import 'package:ecclesia/features/liturgy/data/datasources/local_service_datasource.dart';
import 'package:ecclesia/features/liturgy/data/repositories/preacher_assignment_repository_impl.dart';
import 'package:ecclesia/features/liturgy/data/repositories/service_repository_impl.dart';
import 'package:ecclesia/features/liturgy/domain/entities/preacher_assignment.dart';
import 'package:ecclesia/features/liturgy/domain/entities/service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ServiceRepositoryImpl serviceRepository;
  late PreacherAssignmentRepositoryImpl assignmentRepository;

  const churchId = 'church-1';

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.into(db.churches).insert(
        ChurchesCompanion.insert(id: churchId, code: 'RTC', name: 'RTC-MALI'));
    serviceRepository = ServiceRepositoryImpl(LocalServiceDataSource(db));
    assignmentRepository =
        PreacherAssignmentRepositoryImpl(LocalPreacherAssignmentDataSource(db));
  });

  tearDown(() async {
    await db.close();
  });

  group('ServiceRepositoryImpl', () {
    test('createService puis getServiceById retrouve le même culte', () async {
      final service = Service(
        id: 'service-1',
        churchId: churchId,
        date: DateTime(2026, 9, 13, 10),
        type: ServiceType.dominical,
        theme: 'La grâce',
      );
      await serviceRepository.createService(service);

      final result = await serviceRepository.getServiceById('service-1');
      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (found) => expect(found.theme, 'La grâce'),
      );
    });

    test('updateServiceStatus change le statut du culte', () async {
      await serviceRepository.createService(Service(
        id: 'service-1',
        churchId: churchId,
        date: DateTime(2026, 9, 13),
        type: ServiceType.dominical,
      ));

      final result = await serviceRepository.updateServiceStatus(
        id: 'service-1',
        status: ServiceStatus.held,
      );
      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (updated) => expect(updated.status, ServiceStatus.held),
      );
    });

    test('getServicesForChurch filtre par plage de dates', () async {
      await serviceRepository.createService(Service(
        id: 'service-old',
        churchId: churchId,
        date: DateTime(2026, 1, 5),
        type: ServiceType.dominical,
      ));
      await serviceRepository.createService(Service(
        id: 'service-in-range',
        churchId: churchId,
        date: DateTime(2026, 9, 13),
        type: ServiceType.dominical,
      ));

      final result = await serviceRepository.getServicesForChurch(
        churchId: churchId,
        from: DateTime(2026, 9, 1),
        to: DateTime(2026, 9, 30),
      );
      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (services) {
          expect(services.length, 1);
          expect(services.first.id, 'service-in-range');
        },
      );
    });
  });

  group('PreacherAssignmentRepositoryImpl', () {
    test('assignPreacher puis getAssignmentsForService retrouve l\'affectation',
        () async {
      await serviceRepository.createService(Service(
        id: 'service-1',
        churchId: churchId,
        date: DateTime(2026, 9, 13),
        type: ServiceType.dominical,
      ));

      await assignmentRepository.assignPreacher(const PreacherAssignment(
        id: 'assign-1',
        serviceId: 'service-1',
        externalName: 'Rév. Kalonji',
      ));

      final result =
          await assignmentRepository.getAssignmentsForService('service-1');
      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (assignments) {
          expect(assignments.length, 1);
          expect(assignments.first.isExternal, isTrue);
          expect(assignments.first.externalName, 'Rév. Kalonji');
        },
      );
    });
  });
}
