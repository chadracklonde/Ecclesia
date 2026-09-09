import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';

class LocalInventoryDataSource {
  final AppDatabase db;

  LocalInventoryDataSource(this.db);

  Future<void> insert(InventoryItemsCompanion companion) {
    return db.into(db.inventoryItems).insert(companion);
  }

  Future<void> update(String id, InventoryItemsCompanion companion) {
    return (db.update(db.inventoryItems)..where((i) => i.id.equals(id)))
        .write(companion);
  }

  Future<List<InventoryItemRow>> getForChurch(String churchId) {
    return (db.select(db.inventoryItems)
          ..where((i) =>
              i.churchId.equals(churchId) & i.isDeleted.equals(false)))
        .get();
  }

  /// Suppression douce (`isDeleted`), cohérent avec le reste du projet —
  /// jamais de `DELETE` physique sur les entités métier.
  Future<void> softDelete(String id) {
    return (db.update(db.inventoryItems)..where((i) => i.id.equals(id))).write(
      InventoryItemsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
