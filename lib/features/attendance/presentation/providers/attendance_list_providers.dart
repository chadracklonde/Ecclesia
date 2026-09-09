import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../members/domain/entities/member.dart';
import '../../domain/entities/attendance.dart';
import 'attendance_providers.dart';

final todayAttendanceProvider =
    FutureProvider.family<List<Attendance>, String>((ref, churchId) async {
  final getAttendance = ref.watch(getAttendanceForDateUseCaseProvider);
  final result =
      await getAttendance(churchId: churchId, date: DateTime.now());
  return result.fold(
    (failure) => throw Exception(failure.message),
    (attendances) => attendances,
  );
});

/// Membres non vus depuis 30 jours — seuil indicatif, non prescrit par
/// l'Étape 0 (qui ne fixait aucune durée) ; à rendre configurable si le
/// besoin pastoral réel diffère.
final membersToVisitProvider =
    FutureProvider.family<List<Member>, String>((ref, churchId) async {
  final getMembersToVisit = ref.watch(getMembersToVisitProvider);
  final sinceDate = DateTime.now().subtract(const Duration(days: 30));
  final result =
      await getMembersToVisit(churchId: churchId, sinceDate: sinceDate);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (members) => members,
  );
});
