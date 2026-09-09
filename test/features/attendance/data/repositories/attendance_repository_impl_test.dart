import 'package:drift/native.dart';
import 'package:ecclesia/core/database/database.dart';
import 'package:ecclesia/features/attendance/data/datasources/local_attendance_datasource.dart';
import 'package:ecclesia/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:ecclesia/features/attendance/domain/entities/attendance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late AttendanceRepositoryImpl repository;

  const churchId = 'church-1';
  const memberId = 'member-1';

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.into(db.churches).insert(
        ChurchesCompanion.insert(id: churchId, code: 'RTC', name: 'RTC-MALI'));
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
    repository = AttendanceRepositoryImpl(LocalAttendanceDataSource(db));
  });

  tearDown(() async {
    await db.close();
  });

  Attendance buildAttendance({DateTime? date}) => Attendance(
        id: 'attendance-1',
        churchId: churchId,
        memberId: memberId,
        attendanceDate: date ?? DateTime(2026, 9, 13),
        checkInTime: DateTime(2026, 9, 13, 10, 5),
        method: AttendanceMethod.manual,
        status: AttendanceStatus.present,
      );

  group('AttendanceRepositoryImpl', () {
    test('recordPresence insère une nouvelle ligne', () async {
      final result = await repository.recordPresence(buildAttendance());
      expect(result.isSuccess, isTrue);

      final forDate = await repository.getAttendanceForDate(
        churchId: churchId,
        date: DateTime(2026, 9, 13),
      );
      forDate.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (rows) => expect(rows.length, 1),
      );
    });

    test('pointer deux fois le même membre le même jour ne duplique pas la ligne',
        () async {
      await repository.recordPresence(buildAttendance());
      await repository.recordPresence(buildAttendance(
          date: DateTime(2026, 9, 13, 14))); // même jour, heure différente

      final forDate = await repository.getAttendanceForDate(
        churchId: churchId,
        date: DateTime(2026, 9, 13),
      );
      forDate.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (rows) => expect(rows.length, 1),
      );
    });

    test('getMemberIdsPresentSince retrouve un membre pointé récemment',
        () async {
      await repository.recordPresence(buildAttendance(date: DateTime(2026, 9, 13)));

      final result = await repository.getMemberIdsPresentSince(
        churchId: churchId,
        sinceDate: DateTime(2026, 9, 1),
      );
      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (ids) => expect(ids, contains(memberId)),
      );
    });

    test('getMemberIdsPresentSince ignore un pointage trop ancien', () async {
      await repository.recordPresence(buildAttendance(date: DateTime(2026, 1, 5)));

      final result = await repository.getMemberIdsPresentSince(
        churchId: churchId,
        sinceDate: DateTime(2026, 9, 1),
      );
      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (ids) => expect(ids, isNot(contains(memberId))),
      );
    });
  });
}
