import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

class CreateInventoryItem {
  final InventoryRepository repository;
  final Uuid uuid;

  CreateInventoryItem({required this.repository, Uuid? uuid})
      : uuid = uuid ?? const Uuid();

  Future<Result<InventoryItem>> call({
    required String churchId,
    required String name,
    String? category,
    int quantity = 1,
    String? condition,
    String? location,
    DateTime? acquiredDate,
  }) async {
    if (name.trim().isEmpty) {
      return const Error(ValidationFailure('Le nom de l\'article est obligatoire'));
    }
    if (quantity < 0) {
      return const Error(
          ValidationFailure('La quantité ne peut pas être négative'));
    }

    final item = InventoryItem(
      id: uuid.v4(),
      churchId: churchId,
      name: name.trim(),
      category: category,
      quantity: quantity,
      condition: condition,
      location: location,
      acquiredDate: acquiredDate,
    );

    return repository.createItem(item);
  }
}

class UpdateInventoryItem {
  final InventoryRepository repository;

  UpdateInventoryItem(this.repository);

  Future<Result<InventoryItem>> call(InventoryItem item) async {
    if (item.name.trim().isEmpty) {
      return const Error(ValidationFailure('Le nom de l\'article est obligatoire'));
    }
    if (item.quantity < 0) {
      return const Error(
          ValidationFailure('La quantité ne peut pas être négative'));
    }
    return repository.updateItem(item);
  }
}

class ListInventoryItems {
  final InventoryRepository repository;

  ListInventoryItems(this.repository);

  Future<Result<List<InventoryItem>>> call({required String churchId}) {
    return repository.getItemsForChurch(churchId: churchId);
  }
}

class DeleteInventoryItem {
  final InventoryRepository repository;

  DeleteInventoryItem(this.repository);

  Future<Result<void>> call(String id) {
    return repository.deleteItem(id);
  }
}
