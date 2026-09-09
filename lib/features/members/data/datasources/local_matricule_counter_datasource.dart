import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';

class LocalMatriculeCounterDataSource {
  final AppDatabase db;

  LocalMatriculeCounterDataSource(this.db);

  /// Incrémente et retourne le prochain numéro de séquence, dans une
  /// transaction — évite toute course entre deux créations simultanées.
  Future<int> nextSequence({
    required String churchId,
    required int year,
  }) {
    final counterId = '$churchId-$year';
    return db.transaction(() async {
      final existing = await (db.select(db.matriculeCounters)
            ..where((c) => c.id.equals(counterId)))
          .getSingleOrNull();

      if (existing == null) {
        await db.into(db.matriculeCounters).insert(
              MatriculeCountersCompanion.insert(
                id: counterId,
                churchId: churchId,
                year: year,
                lastSequence: const Value(1),
              ),
            );
        return 1;
      }

      final next = existing.lastSequence + 1;
      await (db.update(db.matriculeCounters)
            ..where((c) => c.id.equals(counterId)))
          .write(MatriculeCountersCompanion(lastSequence: Value(next)));
      return next;
    });
  }
}
