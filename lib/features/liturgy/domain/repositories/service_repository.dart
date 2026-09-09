import '../../../../core/utils/result.dart';
import '../entities/service.dart';

abstract class ServiceRepository {
  Future<Result<Service>> createService(Service service);

  Future<Result<Service>> getServiceById(String id);

  Future<Result<List<Service>>> getServicesForChurch({
    required String churchId,
    DateTime? from,
    DateTime? to,
  });

  Future<Result<Service>> updateServiceStatus({
    required String id,
    required ServiceStatus status,
  });
}
