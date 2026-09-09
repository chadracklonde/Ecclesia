import '../../../../core/utils/result.dart';
import '../entities/inventory_item.dart';

abstract class InventoryRepository {
  Future<Result<InventoryItem>> createItem(InventoryItem item);

  Future<Result<InventoryItem>> updateItem(InventoryItem item);

  Future<Result<List<InventoryItem>>> getItemsForChurch({
    required String churchId,
  });

  Future<Result<void>> deleteItem(String id);
}
