import 'package:drift/native.dart';
import 'package:ecclesia/core/database/database.dart';
import 'package:ecclesia/features/finance/data/datasources/local_finance_datasource.dart';
import 'package:ecclesia/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:ecclesia/features/finance/domain/entities/financial_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late FinanceRepositoryImpl repository;

  const churchId = 'church-1';

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.into(db.churches).insert(
        ChurchesCompanion.insert(id: churchId, code: 'RTC', name: 'RTC-MALI'));
    repository = FinanceRepositoryImpl(LocalFinanceDataSource(db));
  });

  tearDown(() async {
    await db.close();
  });

  FinancialTransaction buildTransaction({
    required String id,
    required TransactionType type,
    required int amountCents,
    DateTime? date,
  }) =>
      FinancialTransaction(
        id: id,
        churchId: churchId,
        type: type,
        amountCents: amountCents,
        transactionDate: date ?? DateTime(2026, 9, 13),
      );

  group('FinanceRepositoryImpl', () {
    test('createTransaction puis getById retrouve la même transaction',
        () async {
      final tx = buildTransaction(
          id: 'tx-1', type: TransactionType.dime, amountCents: 15000);
      await repository.createTransaction(tx);

      final result = await repository.getTransactionById('tx-1');
      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (found) => expect(found.amountCents, 15000),
      );
    });

    test('cancelTransaction marque annulée avec motif, ne supprime rien',
        () async {
      final tx = buildTransaction(
          id: 'tx-1', type: TransactionType.offrande, amountCents: 5000);
      await repository.createTransaction(tx);

      final result = await repository.cancelTransaction(
          id: 'tx-1', reason: 'Erreur de saisie');
      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (cancelled) {
          expect(cancelled.isCancelled, isTrue);
          expect(cancelled.cancelledReason, 'Erreur de saisie');
        },
      );

      // La transaction reste lisible (pas supprimée).
      final stillThere = await repository.getTransactionById('tx-1');
      expect(stillThere.isSuccess, isTrue);
    });

    test('annuler deux fois la même transaction échoue la deuxième fois',
        () async {
      final tx = buildTransaction(
          id: 'tx-1', type: TransactionType.offrande, amountCents: 5000);
      await repository.createTransaction(tx);
      await repository.cancelTransaction(id: 'tx-1', reason: 'Première annulation');

      final second = await repository.cancelTransaction(
          id: 'tx-1', reason: 'Deuxième tentative');
      expect(second.isSuccess, isFalse);
    });

    test('getCashBalanceCents = revenus actifs - dépenses actives, exclut les annulées',
        () async {
      await repository.createTransaction(buildTransaction(
          id: 'tx-1', type: TransactionType.dime, amountCents: 10000));
      await repository.createTransaction(buildTransaction(
          id: 'tx-2', type: TransactionType.offrande, amountCents: 5000));
      await repository.createTransaction(buildTransaction(
          id: 'tx-3', type: TransactionType.depense, amountCents: 3000));
      // Cette offrande sera annulée : ne doit PAS compter dans le solde.
      await repository.createTransaction(buildTransaction(
          id: 'tx-4', type: TransactionType.offrande, amountCents: 20000));
      await repository.cancelTransaction(id: 'tx-4', reason: 'Doublon');

      final result = await repository.getCashBalanceCents(churchId: churchId);
      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        // (10000 + 5000) - 3000 = 12000 ; les 20000 annulés sont exclus.
        (balance) => expect(balance, 12000),
      );
    });

    test('getTransactionsForChurch filtre correctement par plage de dates',
        () async {
      await repository.createTransaction(buildTransaction(
          id: 'tx-old',
          type: TransactionType.dime,
          amountCents: 1000,
          date: DateTime(2026, 1, 5)));
      await repository.createTransaction(buildTransaction(
          id: 'tx-in-range',
          type: TransactionType.dime,
          amountCents: 2000,
          date: DateTime(2026, 9, 13)));

      final result = await repository.getTransactionsForChurch(
        churchId: churchId,
        from: DateTime(2026, 9, 1),
        to: DateTime(2026, 9, 30),
      );
      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (transactions) {
          expect(transactions.length, 1);
          expect(transactions.first.id, 'tx-in-range');
        },
      );
    });
  });
}
