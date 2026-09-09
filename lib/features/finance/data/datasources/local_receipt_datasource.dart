import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';

class LocalReceiptDataSource {
  final AppDatabase db;

  LocalReceiptDataSource(this.db);

  Future<void> insert(ReceiptsCompanion companion) {
    return db.into(db.receipts).insert(companion);
  }

  Future<ReceiptRow?> getForTransaction(String transactionId) {
    return (db.select(db.receipts)
          ..where((r) => r.transactionId.equals(transactionId)))
        .getSingleOrNull();
  }

  Future<void> cancel(String id) {
    return (db.update(db.receipts)..where((r) => r.id.equals(id))).write(
      ReceiptsCompanion(
        isCancelled: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
