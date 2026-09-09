import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/local_inventory_datasource.dart';
import '../models/secretariat_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final LocalInventoryDataSource dataSource;

  InventoryRepositoryImpl(this.dataSource);

  @override
  Future<Result<InventoryItem>> createItem(InventoryItem item) async {
    try {
      await dataSource.insert(item.toInsertCompanion());
      return Success(item);
    } catch (e) {
      return Error(DatabaseFailure('Échec de la création de l\'article : $e'));
    }
  }

  @override
  Future<Result<InventoryItem>> updateItem(InventoryItem item) async {
    try {
      await dataSource.update(item.id, item.toUpdateCompanion());
      return Success(item);
    } catch (e) {
      return Error(
          DatabaseFailure('Échec de la mise à jour de l\'article : $e'));
    }
  }

  @override
  Future<Result<List<InventoryItem>>> getItemsForChurch({
    required String churchId,
  }) async {
    try {
      final rows = await dataSource.getForChurch(churchId);
      return Success(rows.map((r) => r.toDomain()).toList());
    } catch (e) {
      return Error(
          DatabaseFailure('Échec de la lecture de l\'inventaire : $e'));
    }
  }

  @override
  Future<Result<void>> deleteItem(String id) async {
    try {
      await dataSource.softDelete(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Échec de la suppression de l\'article : $e'));
    }
  }
}
