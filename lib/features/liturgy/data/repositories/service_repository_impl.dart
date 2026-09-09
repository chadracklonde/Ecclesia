import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/service.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasources/local_service_datasource.dart';
import '../models/liturgy_model.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final LocalServiceDataSource dataSource;

  ServiceRepositoryImpl(this.dataSource);

  @override
  Future<Result<Service>> createService(Service service) async {
    try {
      await dataSource.insert(service.toCompanion());
      return Success(service);
    } catch (e) {
      return Error(DatabaseFailure('Échec de la création du culte : $e'));
    }
  }

  @override
  Future<Result<Service>> getServiceById(String id) async {
    try {
      final row = await dataSource.getById(id);
      if (row == null) {
        return const Error(NotFoundFailure('Culte introuvable'));
      }
      return Success(row.toDomain());
    } catch (e) {
      return Error(DatabaseFailure('Échec de la lecture du culte : $e'));
    }
  }

  @override
  Future<Result<List<Service>>> getServicesForChurch({
    required String churchId,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final rows =
          await dataSource.getForChurch(churchId: churchId, from: from, to: to);
      return Success(rows.map((r) => r.toDomain()).toList());
    } catch (e) {
      return Error(DatabaseFailure('Échec de la lecture des cultes : $e'));
    }
  }

  @override
  Future<Result<Service>> updateServiceStatus({
    required String id,
    required ServiceStatus status,
  }) async {
    try {
      final existing = await dataSource.getById(id);
      if (existing == null) {
        return const Error(NotFoundFailure('Culte introuvable'));
      }
      await dataSource.updateStatus(id, serviceStatusToString(status));
      final updated = await dataSource.getById(id);
      return Success(updated!.toDomain());
    } catch (e) {
      return Error(DatabaseFailure('Échec de la mise à jour du culte : $e'));
    }
  }
}
