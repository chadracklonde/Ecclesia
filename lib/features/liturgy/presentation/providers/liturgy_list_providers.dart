import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/preacher_assignment.dart';
import '../../domain/entities/service.dart';
import 'liturgy_providers.dart';

final servicesListProvider =
    FutureProvider.family<List<Service>, String>((ref, churchId) async {
  final listServices = ref.watch(listServicesUseCaseProvider);
  final result = await listServices(churchId: churchId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (services) => services,
  );
});

final preachersForServiceProvider =
    FutureProvider.family<List<PreacherAssignment>, String>((ref, serviceId) async {
  final getPreachers = ref.watch(getPreachersForServiceProvider);
  final result = await getPreachers(serviceId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (assignments) => assignments,
  );
});
