import 'package:drift/native.dart';
import 'package:ecclesia/core/database/database.dart';
import 'package:ecclesia/features/classes_subgroups/data/datasources/local_church_class_datasource.dart';
import 'package:ecclesia/features/classes_subgroups/data/datasources/local_subgroup_datasource.dart';
import 'package:ecclesia/features/classes_subgroups/data/repositories/church_class_repository_impl.dart';
import 'package:ecclesia/features/classes_subgroups/data/repositories/subgroup_repository_impl.dart';
import 'package:ecclesia/features/classes_subgroups/domain/entities/church_class.dart';
import 'package:ecclesia/features/classes_subgroups/domain/entities/subgroup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ChurchClassRepositoryImpl classRepository;
  late SubgroupRepositoryImpl subgroupRepository;

  const churchId = 'church-1';
  const memberId = 'member-1';

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.into(db.churches).insert(
        ChurchesCompanion.insert(id: churchId, code: 'RTC', name: 'RTC-MALI'));
    // Un membre minimal, juste pour satisfaire les clés étrangères des
    // tables de rattachement — la validité complète du membre est du
    // ressort du module Membres (Étape 3), déjà testé séparément.
    await db.into(db.members).insert(MembersCompanion.insert(
          id: memberId,
          churchId: churchId,
          matricule: 'RTC-2026-0001',
          firstName: 'Jeanne',
          lastName: 'Mukendi',
          sex: 'F',
          status: 'probation',
          statusSince: DateTime(2026),
          joinDate: DateTime(2026),
        ));
    classRepository = ChurchClassRepositoryImpl(LocalChurchClassDataSource(db));
    subgroupRepository = SubgroupRepositoryImpl(LocalSubgroupDataSource(db));
  });

  tearDown(() async {
    await db.close();
  });

  group('ChurchClassRepositoryImpl', () {
    test('un membre peut être rattaché à plusieurs classes simultanément '
        '(Étape 0, décision #1)', () async {
      await classRepository.createClass(const ChurchClass(
          id: 'class-1', churchId: churchId, name: 'Classe Emmanuel'));
      await classRepository.createClass(const ChurchClass(
          id: 'class-2', churchId: churchId, name: 'Classe Bethel'));

      await classRepository.assignMemberToClass(
          memberId: memberId, classId: 'class-1');
      await classRepository.assignMemberToClass(
          memberId: memberId, classId: 'class-2');

      final result = await classRepository.getClassIdsForMember(memberId);
      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (classIds) {
          expect(classIds.length, 2);
          expect(classIds, containsAll(['class-1', 'class-2']));
        },
      );
    });

    test('removeMemberFromClass retire uniquement le rattachement visé',
        () async {
      await classRepository.createClass(const ChurchClass(
          id: 'class-1', churchId: churchId, name: 'Classe Emmanuel'));
      await classRepository.createClass(const ChurchClass(
          id: 'class-2', churchId: churchId, name: 'Classe Bethel'));
      await classRepository.assignMemberToClass(
          memberId: memberId, classId: 'class-1');
      await classRepository.assignMemberToClass(
          memberId: memberId, classId: 'class-2');

      await classRepository.removeMemberFromClass(
          memberId: memberId, classId: 'class-1');

      final result = await classRepository.getClassIdsForMember(memberId);
      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (classIds) => expect(classIds, ['class-2']),
      );
    });

    test('assigner deux fois le même rattachement ne duplique pas la ligne',
        () async {
      await classRepository.createClass(const ChurchClass(
          id: 'class-1', churchId: churchId, name: 'Classe Emmanuel'));

      await classRepository.assignMemberToClass(
          memberId: memberId, classId: 'class-1');
      await classRepository.assignMemberToClass(
          memberId: memberId, classId: 'class-1');

      final result = await classRepository.getClassIdsForMember(memberId);
      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (classIds) => expect(classIds.length, 1),
      );
    });
  });

  group('SubgroupRepositoryImpl', () {
    test('un membre peut être rattaché à plusieurs sous-groupes, avec rôle',
        () async {
      await subgroupRepository.createSubgroup(const Subgroup(
          id: 'sg-1', churchId: churchId, name: 'Chorale', type: 'chorale'));
      await subgroupRepository.createSubgroup(const Subgroup(
          id: 'sg-2', churchId: churchId, name: 'Jeunesse', type: 'jeunesse'));

      await subgroupRepository.assignMemberToSubgroup(
          memberId: memberId, subgroupId: 'sg-1', roleInGroup: 'responsable');
      await subgroupRepository.assignMemberToSubgroup(
          memberId: memberId, subgroupId: 'sg-2');

      final result = await subgroupRepository.getSubgroupIdsForMember(memberId);
      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (subgroupIds) {
          expect(subgroupIds.length, 2);
          expect(subgroupIds, containsAll(['sg-1', 'sg-2']));
        },
      );
    });
  });
}
