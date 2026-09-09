import 'package:uuid/uuid.dart';

import '../../../../core/utils/result.dart';
import '../entities/attendance.dart';
import '../repositories/attendance_repository.dart';

class RecordPresence {
  final AttendanceRepository repository;
  final Uuid uuid;

  RecordPresence({required this.repository, Uuid? uuid})
      : uuid = uuid ?? const Uuid();

  Future<Result<Attendance>> call({
    required String churchId,
    required String memberId,
    required AttendanceMethod method,
    DateTime? date,
  }) {
    final now = DateTime.now();
    final attendance = Attendance(
      id: uuid.v4(),
      churchId: churchId,
      memberId: memberId,
      attendanceDate: date ?? now,
      checkInTime: now,
      method: method,
      status: AttendanceStatus.present,
    );
    return repository.recordPresence(attendance);
  }
}
