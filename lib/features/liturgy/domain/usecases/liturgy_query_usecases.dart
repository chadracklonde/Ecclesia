import 'package:uuid/uuid.dart';

import '../../../../core/utils/result.dart';
import '../entities/preacher_assignment.dart';
import '../entities/service.dart';
import '../repositories/preacher_assignment_repository.dart';
import '../repositories/service_repository.dart';

class CreateService {
  final ServiceRepository repository;
  final Uuid uuid;

  CreateService({required this.repository, Uuid? uuid})
      : uuid = uuid ?? const Uuid();

  Future<Result<Service>> call({
    required String churchId,
    required DateTime date,
    required ServiceType type,
    String? theme,
  }) {
    final service = Service(
      id: uuid.v4(),
      churchId: churchId,
      date: date,
      type: type,
      theme: theme,
    );
    return repository.createService(service);
  }
}

class ListServices {
  final ServiceRepository repository;

  ListServices(this.repository);

  Future<Result<List<Service>>> call({
    required String churchId,
    DateTime? from,
    DateTime? to,
  }) {
    return repository.getServicesForChurch(churchId: churchId, from: from, to: to);
  }
}

class GetPreachersForService {
  final PreacherAssignmentRepository repository;

  GetPreachersForService(this.repository);

  Future<Result<List<PreacherAssignment>>> call(String serviceId) {
    return repository.getAssignmentsForService(serviceId);
  }
}
