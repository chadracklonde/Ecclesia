import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../members/presentation/providers/member_providers.dart';
import '../../data/datasources/local_preacher_assignment_datasource.dart';
import '../../data/datasources/local_service_datasource.dart';
import '../../data/repositories/preacher_assignment_repository_impl.dart';
import '../../data/repositories/service_repository_impl.dart';
import '../../domain/repositories/preacher_assignment_repository.dart';
import '../../domain/repositories/service_repository.dart';
import '../../domain/usecases/assign_preacher.dart';
import '../../domain/usecases/liturgy_query_usecases.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ServiceRepositoryImpl(LocalServiceDataSource(db));
});

final preacherAssignmentRepositoryProvider =
    Provider<PreacherAssignmentRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PreacherAssignmentRepositoryImpl(LocalPreacherAssignmentDataSource(db));
});

final createServiceProvider = Provider<CreateService>((ref) {
  return CreateService(repository: ref.watch(serviceRepositoryProvider));
});

final listServicesUseCaseProvider = Provider<ListServices>((ref) {
  return ListServices(ref.watch(serviceRepositoryProvider));
});

final getPreachersForServiceProvider = Provider<GetPreachersForService>((ref) {
  return GetPreachersForService(ref.watch(preacherAssignmentRepositoryProvider));
});

final assignPreacherProvider = Provider<AssignPreacher>((ref) {
  return AssignPreacher(
    assignmentRepository: ref.watch(preacherAssignmentRepositoryProvider),
    serviceRepository: ref.watch(serviceRepositoryProvider),
    memberRepository: ref.watch(memberRepositoryProvider),
  );
});
