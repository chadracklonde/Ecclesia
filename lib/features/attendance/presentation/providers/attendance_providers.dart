import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../members/presentation/providers/member_providers.dart';
import '../../data/datasources/local_attendance_datasource.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/usecases/get_attendance_for_date.dart';
import '../../domain/usecases/get_members_to_visit.dart';
import '../../domain/usecases/record_presence.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AttendanceRepositoryImpl(LocalAttendanceDataSource(db));
});

final recordPresenceProvider = Provider<RecordPresence>((ref) {
  return RecordPresence(repository: ref.watch(attendanceRepositoryProvider));
});

final getAttendanceForDateUseCaseProvider = Provider<GetAttendanceForDate>((ref) {
  return GetAttendanceForDate(ref.watch(attendanceRepositoryProvider));
});

final getMembersToVisitProvider = Provider<GetMembersToVisit>((ref) {
  return GetMembersToVisit(
    memberRepository: ref.watch(memberRepositoryProvider),
    attendanceRepository: ref.watch(attendanceRepositoryProvider),
  );
});
