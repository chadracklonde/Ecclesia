import 'package:drift/native.dart';
import 'package:ecclesia/core/database/database.dart';
import 'package:ecclesia/features/members/data/datasources/local_member_datasource.dart';
import 'package:ecclesia/features/members/data/repositories/member_repository_impl.dart';
import 'package:ecclesia/features/members/domain/entities/member.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late MemberRepositoryImpl repository;

  const churchId = 'church-1';

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db
        .into(db.churches)
        .insert(ChurchesCompanion.insert(id: churchId, code: 'RTC', name: 'RTC-MALI'));
    repository = MemberRepositoryImpl(LocalMemberDataSource(db));
  });

  tearDown(() async {
    await db.close();
  });

  Member buildMember({String id = 'member-1', String matricule = 'RTC-2026-0001'}) {
    final now = DateTime(2026, 9, 9);
    return Member(
      id: id,
      churchId: churchId,
      matricule: matricule,
      firstName: 'Jeanne',
      lastName: 'Mukendi',
      sex: Sex.female,
      status: MemberStatus.probation,
      statusSince: now,
      joinDate: now,
    );
  }

  group('MemberRepositoryImpl', () {
    test('createMember puis getMemberById retrouve le même membre', () async {
      final member = buildMember();

      final createResult = await repository.createMember(member);
      expect(createResult.isSuccess, isTrue);

      final getResult = await repository.getMemberById(member.id);
      getResult.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (found) {
          expect(found.id, member.id);
          expect(found.matricule, member.matricule);
          expect(found.status, MemberStatus.probation);
        },
      );
    });

    test('getMemberById renvoie NotFoundFailure pour un id inconnu', () async {
      final result = await repository.getMemberById('inconnu');
      expect(result.isSuccess, isFalse);
    });

    test(
        'updateMemberStatus change le statut ET insère une ligne d\'historique (atomicité)',
        () async {
      final member = buildMember();
      await repository.createMember(member);

      final updateResult = await repository.updateMemberStatus(
        memberId: member.id,
        newStatus: MemberStatus.fullMember,
        note: 'Passage en pleine communion après catéchisme',
        recordedBy: 'user-1',
      );

      updateResult.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (updated) => expect(updated.status, MemberStatus.fullMember),
      );

      final historyRows = await (db.select(db.statusHistories)
            ..where((h) => h.memberId.equals(member.id)))
          .get();
      expect(historyRows.length, 1);
      expect(historyRows.first.oldStatus, 'probation');
      expect(historyRows.first.newStatus, 'full_member');
    });

    test('getAllMembers filtre bien par churchId', () async {
      await repository.createMember(buildMember(id: 'm1', matricule: 'RTC-2026-0001'));
      await repository.createMember(buildMember(id: 'm2', matricule: 'RTC-2026-0002'));

      final result = await repository.getAllMembers(churchId: churchId);
      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (members) => expect(members.length, 2),
      );
    });
  });
}
