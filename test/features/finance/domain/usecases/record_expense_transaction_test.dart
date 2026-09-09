import 'package:ecclesia/core/utils/result.dart';
import 'package:ecclesia/features/finance/domain/entities/financial_transaction.dart';
import 'package:ecclesia/features/finance/domain/repositories/finance_repository.dart';
import 'package:ecclesia/features/finance/domain/usecases/record_expense_transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFinanceRepository extends Mock implements FinanceRepository {}

void main() {
  late MockFinanceRepository financeRepository;
  late RecordExpenseTransaction recordExpenseTransaction;

  setUpAll(() {
    registerFallbackValue(FinancialTransaction(
      id: 'fallback',
      churchId: 'church-1',
      type: TransactionType.depense,
      amountCents: 1,
      transactionDate: DateTime(2026),
    ));
  });

  setUp(() {
    financeRepository = MockFinanceRepository();
    recordExpenseTransaction =
        RecordExpenseTransaction(financeRepository: financeRepository);
  });

  group('RecordExpenseTransaction', () {
    test('rejette un montant nul ou négatif sans appeler le repository',
        () async {
      final result = await recordExpenseTransaction(
        churchId: 'church-1',
        amountCents: -100,
        category: 'Électricité',
      );

      expect(result, isA<Error<FinancialTransaction>>());
      verifyNever(() => financeRepository.createTransaction(any()));
    });

    test('rejette une catégorie vide sans appeler le repository', () async {
      final result = await recordExpenseTransaction(
        churchId: 'church-1',
        amountCents: 3000,
        category: '   ',
      );

      expect(result, isA<Error<FinancialTransaction>>());
      verifyNever(() => financeRepository.createTransaction(any()));
    });

    test('cas nominal : crée une transaction de type depense', () async {
      when(() => financeRepository.createTransaction(any()))
          .thenAnswer((invocation) async {
        final tx =
            invocation.positionalArguments.first as FinancialTransaction;
        return Success(tx);
      });

      final result = await recordExpenseTransaction(
        churchId: 'church-1',
        amountCents: 3000,
        category: 'Électricité',
      );

      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (tx) {
          expect(tx.type, TransactionType.depense);
          expect(tx.category, 'Électricité');
        },
      );
    });
  });
}
