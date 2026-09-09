import '../../../../core/utils/result.dart';
import '../entities/attendance.dart';

abstract class AttendanceRepository {
  /// Enregistre une présence. Si le membre a déjà un pointage pour la
  /// même date, la ligne existante est mise à jour plutôt que dupliquée.
  Future<Result<Attendance>> recordPresence(Attendance attendance);

  Future<Result<List<Attendance>>> getAttendanceForDate({
    required String churchId,
    required DateTime date,
  });

  Future<Result<List<Attendance>>> getAttendanceHistoryForMember(
    String memberId,
  );

  /// Identifiants des membres ayant au moins un pointage "présent" depuis
  /// `sinceDate` — sert de base au suivi pastoral (qui n'a pas été vu
  /// depuis longtemps).
  Future<Result<List<String>>> getMemberIdsPresentSince({
    required String churchId,
    required DateTime sinceDate,
  });
}
