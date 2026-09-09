import 'package:equatable/equatable.dart';

enum AttendanceStatus { present, absent, late }

enum AttendanceMethod { qrScan, manual }

/// Centrée sur la date, pas sur un culte (Étape 0, décision #8, révisée
/// le 09/09/2026) : sert d'abord le suivi pastoral.
class Attendance extends Equatable {
  final String id;
  final String churchId;
  final String memberId;
  final String? serviceId;
  final DateTime attendanceDate;
  final DateTime? checkInTime;
  final AttendanceMethod method;
  final AttendanceStatus status;
  final String? note;

  const Attendance({
    required this.id,
    required this.churchId,
    required this.memberId,
    this.serviceId,
    required this.attendanceDate,
    this.checkInTime,
    required this.method,
    required this.status,
    this.note,
  });

  @override
  List<Object?> get props => [
        id,
        churchId,
        memberId,
        serviceId,
        attendanceDate,
        checkInTime,
        method,
        status,
        note,
      ];
}
