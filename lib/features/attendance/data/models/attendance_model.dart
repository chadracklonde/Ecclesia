import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../domain/entities/attendance.dart';

String attendanceStatusToString(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return 'present';
    case AttendanceStatus.absent:
      return 'absent';
    case AttendanceStatus.late:
      return 'retard';
  }
}

AttendanceStatus attendanceStatusFromString(String value) {
  switch (value) {
    case 'present':
      return AttendanceStatus.present;
    case 'retard':
      return AttendanceStatus.late;
    default:
      return AttendanceStatus.absent;
  }
}

String attendanceMethodToString(AttendanceMethod method) =>
    method == AttendanceMethod.qrScan ? 'qr_scan' : 'manuel';

AttendanceMethod attendanceMethodFromString(String value) =>
    value == 'qr_scan' ? AttendanceMethod.qrScan : AttendanceMethod.manual;

extension AttendanceRowMapper on AttendanceRow {
  Attendance toDomain() {
    return Attendance(
      id: id,
      churchId: churchId,
      memberId: memberId,
      serviceId: serviceId,
      attendanceDate: attendanceDate,
      checkInTime: checkInTime,
      method: attendanceMethodFromString(method),
      status: attendanceStatusFromString(status),
      note: note,
    );
  }
}

extension AttendanceDomainMapper on Attendance {
  /// Companion complet, utilisé pour l'insertion d'une nouvelle ligne.
  AttendancesCompanion toInsertCompanion({DateTime? overrideDate}) {
    return AttendancesCompanion.insert(
      id: id,
      churchId: churchId,
      memberId: memberId,
      serviceId: Value(serviceId),
      attendanceDate: overrideDate ?? attendanceDate,
      checkInTime: Value(checkInTime),
      method: attendanceMethodToString(method),
      status: attendanceStatusToString(status),
      note: Value(note),
    );
  }

  /// Companion partiel, utilisé pour mettre à jour une ligne existante
  /// (ne touche jamais `id` ni `attendanceDate`, qui identifient la ligne).
  AttendancesCompanion toUpdateCompanion() {
    return AttendancesCompanion(
      status: Value(attendanceStatusToString(status)),
      method: Value(attendanceMethodToString(method)),
      checkInTime: Value(checkInTime),
      updatedAt: Value(DateTime.now()),
    );
  }
}
