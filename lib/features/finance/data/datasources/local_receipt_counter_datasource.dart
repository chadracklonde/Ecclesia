import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';

class LocalReceiptCounterDataSource {
  final AppDatabase db;

  LocalReceiptCounterDataSource(this.db);

  Future<int> nextNumber({
    required String churchId,
    required int year,
  }) {
    final counterId = '$churchId-$year';
    return db.transaction(() async {
      final existing = await (db.select(db.receiptCounters)
            ..where((c) => c.id.equals(counterId)))
          .getSingleOrNull();

      if (existing == null) {
        await db.into(db.receiptCounters).insert(
              ReceiptCountersCompanion.insert(
                id: counterId,
                churchId: churchId,
                year: year,
                lastNumber: const Value(1),
              ),
            );
        return 1;
      }

      final next = existing.lastNumber + 1;
      await (db.update(db.receiptCounters)
            ..where((c) => c.id.equals(counterId)))
          .write(ReceiptCountersCompanion(lastNumber: Value(next)));
      return next;
    });
  }
}
