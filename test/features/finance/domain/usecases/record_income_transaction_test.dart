import 'package:ecclesia/core/errors/failures.dart';
import 'package:ecclesia/core/utils/result.dart';
import 'package:ecclesia/features/finance/domain/entities/financial_transaction.dart';
import 'package:ecclesia/features/finance/domain/entities/receipt.dart';
import 'package:ecclesia/features/finance/domain/repositories/finance_repository.dart';
import 'package:ecclesia/features/finance/domain/repositories/receipt_repository.dart';
import 'package:ecclesia/features/finance/domain/usecases/record_income_transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFinanceRepository extends Mock implements FinanceRepository {}

class MockReceiptRepository extends Mock implements ReceiptRepository {}

void main() {
  late MockFinanceRepository financeRepository;
  late MockReceiptRepository receiptRepository;
  late RecordIncomeTransaction recordIncomeTransaction;

  setUpAll(() {
    registerFallbackValue(FinancialTransaction(
      id: 'fallback',
      churchId: 'church-1',
      type: TransactionType.dime,
      amountCents: 1,
      transactionDate: DateTime(2026),
    ));
  });

  setUp(() {
    financeRepository = MockFinanceRepository();
    receiptRepository = MockReceiptRepository();
    recordIncomeTransaction = RecordIncomeTransaction(
      financeRepository: financeRepository,
      receiptRepository: receiptRepository,
    );
  });

  group('RecordIncomeTransaction', () {
    test('rejette un montant nul ou négatif sans appeler les repositories',
        () async {
      final result = await recordIncomeTransaction(
        churchId: 'church-1',
        type: TransactionType.dime,
        amountCents: 0,
      );

      expect(result, isA<Error<IncomeRecordResult>>());
      verifyNever(() => financeRepository.createTransaction(any()));
    });

    test('rejette le type "depense" (usecase réservé aux revenus)', () async {
      final result = await recordIncomeTransaction(
        churchId: 'church-1',
        type: TransactionType.depense,
        amountCents: 5000,
      );

      expect(result, isA<Error<IncomeRecordResult>>());
      verifyNever(() => financeRepository.createTransaction(any()));
    });

    test('cas nominal : crée la transaction puis génère le reçu', () async {
      when(() => financeRepository.createTransaction(any()))
          .thenAnswer((invocation) async {
        final tx =
            invocation.positionalArguments.first as FinancialTransaction;
        return Success(tx);
      });
      when(() => receiptRepository.issueReceipt(
            churchId: any(named: 'churchId'),
            transactionId: any(named: 'transactionId'),
            issuedBy: any(named: 'issuedBy'),
          )).thenAnswer((invocation) async => Success(Receipt(
            id: 'receipt-1',
            transactionId:
                invocation.namedArguments[#transactionId] as String,
            receiptNumber: 'REC-2026-000001',
            issueDate: DateTime(2026, 9, 13),
          )));

      final result = await recordIncomeTransaction(
        churchId: 'church-1',
        type: TransactionType.offrande,
        amountCents: 5000,
      );

      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (data) {
          expect(data.transaction.amountCents, 5000);
          expect(data.receipt.receiptNumber, 'REC-2026-000001');
        },
      );
    });

    test('propage l\'échec du repository sans tenter de générer un reçu',
        () async {
      when(() => financeRepository.createTransaction(any())).thenAnswer(
          (_) async => const Error(DatabaseFailure('échec simulé')));

      final result = await recordIncomeTransaction(
        churchId: 'church-1',
        type: TransactionType.dime,
        amountCents: 5000,
      );

      expect(result, isA<Error<IncomeRecordResult>>());
      verifyNever(() => receiptRepository.issueReceipt(
            churchId: any(named: 'churchId'),
            transactionId: any(named: 'transactionId'),
          ));
    });
  });
}
