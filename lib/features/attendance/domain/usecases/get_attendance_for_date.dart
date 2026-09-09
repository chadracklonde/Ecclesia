import '../../../../core/utils/result.dart';
import '../entities/attendance.dart';
import '../repositories/attendance_repository.dart';

class GetAttendanceForDate {
  final AttendanceRepository repository;

  GetAttendanceForDate(this.repository);

  Future<Result<List<Attendance>>> call({
    required String churchId,
    required DateTime date,
  }) {
    return repository.getAttendanceForDate(churchId: churchId, date: date);
  }
}
