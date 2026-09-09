import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';

class LocalAttendanceDataSource {
  final AppDatabase db;

  LocalAttendanceDataSource(this.db);

  Future<void> insert(AttendancesCompanion companion) {
    return db.into(db.attendances).insert(companion);
  }

  Future<void> update(String id, AttendancesCompanion companion) {
    return (db.update(db.attendances)..where((a) => a.id.equals(id)))
        .write(companion);
  }

  Future<AttendanceRow?> findByMemberAndDate({
    required String memberId,
    required DateTime date,
  }) {
    return (db.select(db.attendances)
          ..where((a) =>
              a.memberId.equals(memberId) & a.attendanceDate.equals(date)))
        .getSingleOrNull();
  }

  Future<List<AttendanceRow>> getForChurchAndDate({
    required String churchId,
    required DateTime date,
  }) {
    return (db.select(db.attendances)
          ..where(
              (a) => a.churchId.equals(churchId) & a.attendanceDate.equals(date)))
        .get();
  }

  Future<List<AttendanceRow>> getHistoryForMember(String memberId) {
    return (db.select(db.attendances)
          ..where((a) => a.memberId.equals(memberId))
          ..orderBy([(a) => OrderingTerm.desc(a.attendanceDate)]))
        .get();
  }

  /// Membres distincts ayant au moins un pointage "présent" depuis
  /// `sinceDate` (bornes incluses).
  Future<List<String>> getDistinctMemberIdsSince({
    required String churchId,
    required DateTime sinceDate,
  }) async {
    final rows = await (db.select(db.attendances)
          ..where((a) =>
              a.churchId.equals(churchId) &
              a.attendanceDate.isBiggerOrEqualValue(sinceDate) &
              a.status.equals('present')))
        .get();
    return rows.map((r) => r.memberId).toSet().toList();
  }
}
