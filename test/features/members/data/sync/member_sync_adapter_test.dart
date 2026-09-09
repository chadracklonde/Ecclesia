import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:ecclesia/core/database/database.dart';
import 'package:ecclesia/features/members/data/sync/member_sync_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late MemberSyncAdapter adapter;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    adapter = MemberSyncAdapter(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('toRemoteJson puis fromRemoteJson conserve les champs essentiels', () {
    final original = MemberRow(
      id: 'member-1',
      churchId: 'church-1',
      matricule: 'RTC-2026-0001',
      firstName: 'Jeanne',
      lastName: 'Mukendi',
      sex: 'F',
      status: 'probation',
      statusSince: DateTime(2026, 9, 13),
      joinDate: DateTime(2026, 9, 13),
      createdAt: DateTime(2026, 9, 13),
      updatedAt: DateTime(2026, 9, 13, 10),
      isSynced: false,
      isDeleted: false,
    );

    final json = adapter.toRemoteJson(original);
    final roundTripped = adapter.fromRemoteJson(json);

    expect(roundTripped.id, original.id);
    expect(roundTripped.churchId, original.churchId);
    expect(roundTripped.matricule, original.matricule);
    expect(roundTripped.firstName, original.firstName);
    expect(roundTripped.lastName, original.lastName);
    expect(roundTripped.status, original.status);
  });

  test('getUnsyncedLocal ne retourne que les membres non synchronisés',
      () async {
    await db.into(db.churches).insert(
        ChurchesCompanion.insert(id: 'church-1', code: 'RTC', name: 'RTC-MALI'));
    await db.into(db.members).insert(MembersCompanion.insert(
          id: 'm1',
          churchId: 'church-1',
          matricule: 'RTC-2026-0001',
          firstName: 'Jeanne',
          lastName: 'Mukendi',
          sex: 'F',
          status: 'probation',
          statusSince: DateTime(2026),
          joinDate: DateTime(2026),
        ));
    await db.into(db.members).insert(MembersCompanion.insert(
          id: 'm2',
          churchId: 'church-1',
          matricule: 'RTC-2026-0002',
          firstName: 'Paul',
          lastName: 'Ilunga',
          sex: 'M',
          status: 'probation',
          statusSince: DateTime(2026),
          joinDate: DateTime(2026),
          isSynced: const Value(true),
        ));

    final unsynced = await adapter.getUnsyncedLocal();
    expect(unsynced.length, 1);
    expect(unsynced.first.id, 'm1');
  });
}
