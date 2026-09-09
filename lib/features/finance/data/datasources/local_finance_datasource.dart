import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';

class LocalFinanceDataSource {
  final AppDatabase db;

  LocalFinanceDataSource(this.db);

  Future<void> insert(FinancialTransactionsCompanion companion) {
    return db.into(db.financialTransactions).insert(companion);
  }

  Future<FinancialTransactionRow?> getById(String id) {
    return (db.select(db.financialTransactions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<FinancialTransactionRow>> getForChurch({
    required String churchId,
    DateTime? from,
    DateTime? to,
  }) {
    final query = db.select(db.financialTransactions)
      ..where((t) => t.churchId.equals(churchId) & t.isDeleted.equals(false));
    if (from != null) {
      query.where((t) => t.transactionDate.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((t) => t.transactionDate.isSmallerOrEqualValue(to));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.transactionDate)]);
    return query.get();
  }

  Future<void> updateCancellation(
    String id, {
    required DateTime cancelledAt,
    required String reason,
  }) {
    return (db.update(db.financialTransactions)..where((t) => t.id.equals(id)))
        .write(FinancialTransactionsCompanion(
      isCancelled: const Value(true),
      cancelledAt: Value(cancelledAt),
      cancelledReason: Value(reason),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Somme des transactions de revenu (dîme/offrande/quête) actives —
  /// utilisée pour calculer le solde à la volée, jamais stockée.
  Future<int> sumActiveIncomeCents(String churchId) async {
    final rows = await (db.select(db.financialTransactions)
          ..where((t) =>
              t.churchId.equals(churchId) &
              t.isCancelled.equals(false) &
              t.isDeleted.equals(false) &
              t.type.isIn(['dime', 'offrande', 'quete'])))
        .get();
    return rows.fold<int>(0, (sum, r) => sum + r.amountCents);
  }

  Future<int> sumActiveExpenseCents(String churchId) async {
    final rows = await (db.select(db.financialTransactions)
          ..where((t) =>
              t.churchId.equals(churchId) &
              t.isCancelled.equals(false) &
              t.isDeleted.equals(false) &
              t.type.equals('depense')))
        .get();
    return rows.fold<int>(0, (sum, r) => sum + r.amountCents);
  }
}
