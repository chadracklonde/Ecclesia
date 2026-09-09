import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';

class LocalServiceDataSource {
  final AppDatabase db;

  LocalServiceDataSource(this.db);

  Future<void> insert(ServicesCompanion companion) {
    return db.into(db.services).insert(companion);
  }

  Future<ServiceRow?> getById(String id) {
    return (db.select(db.services)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<ServiceRow>> getForChurch({
    required String churchId,
    DateTime? from,
    DateTime? to,
  }) {
    final query = db.select(db.services)
      ..where((s) => s.churchId.equals(churchId) & s.isDeleted.equals(false));
    if (from != null) {
      query.where((s) => s.date.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((s) => s.date.isSmallerOrEqualValue(to));
    }
    query.orderBy([(s) => OrderingTerm.asc(s.date)]);
    return query.get();
  }

  Future<void> updateStatus(String id, String status) {
    return (db.update(db.services)..where((s) => s.id.equals(id))).write(
      ServicesCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
