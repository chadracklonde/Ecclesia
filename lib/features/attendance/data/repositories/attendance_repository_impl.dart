import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/local_attendance_datasource.dart';
import '../models/attendance_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final LocalAttendanceDataSource dataSource;

  AttendanceRepositoryImpl(this.dataSource);

  @override
  Future<Result<Attendance>> recordPresence(Attendance attendance) async {
    try {
      final normalizedDate = DateTime(
        attendance.attendanceDate.year,
        attendance.attendanceDate.month,
        attendance.attendanceDate.day,
      );

      final existing = await dataSource.findByMemberAndDate(
        memberId: attendance.memberId,
        date: normalizedDate,
      );

      if (existing == null) {
        await dataSource
            .insert(attendance.toInsertCompanion(overrideDate: normalizedDate));
        return Success(attendance);
      }

      await dataSource.update(existing.id, attendance.toUpdateCompanion());
      final updated = await dataSource.findByMemberAndDate(
        memberId: attendance.memberId,
        date: normalizedDate,
      );
      return Success(updated!.toDomain());
    } catch (e) {
      return Error(
          DatabaseFailure('Échec de l\'enregistrement de la présence : $e'));
    }
  }

  @override
  Future<Result<List<Attendance>>> getAttendanceForDate({
    required String churchId,
    required DateTime date,
  }) async {
    try {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final rows = await dataSource.getForChurchAndDate(
        churchId: churchId,
        date: normalizedDate,
      );
      return Success(rows.map((r) => r.toDomain()).toList());
    } catch (e) {
      return Error(DatabaseFailure('Échec de la lecture des présences : $e'));
    }
  }

  @override
  Future<Result<List<Attendance>>> getAttendanceHistoryForMember(
    String memberId,
  ) async {
    try {
      final rows = await dataSource.getHistoryForMember(memberId);
      return Success(rows.map((r) => r.toDomain()).toList());
    } catch (e) {
      return Error(
          DatabaseFailure('Échec de la lecture de l\'historique : $e'));
    }
  }

  @override
  Future<Result<List<String>>> getMemberIdsPresentSince({
    required String churchId,
    required DateTime sinceDate,
  }) async {
    try {
      final normalizedDate =
          DateTime(sinceDate.year, sinceDate.month, sinceDate.day);
      final ids = await dataSource.getDistinctMemberIdsSince(
        churchId: churchId,
        sinceDate: normalizedDate,
      );
      return Success(ids);
    } catch (e) {
      return Error(
          DatabaseFailure('Échec de la lecture des présences récentes : $e'));
    }
  }
}
