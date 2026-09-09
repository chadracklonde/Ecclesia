import 'package:ecclesia/core/errors/failures.dart';
import 'package:ecclesia/core/utils/result.dart';
import 'package:ecclesia/features/finance/domain/entities/financial_transaction.dart';
import 'package:ecclesia/features/finance/domain/repositories/finance_repository.dart';
import 'package:ecclesia/features/finance/domain/repositories/receipt_repository.dart';
import 'package:ecclesia/features/finance/domain/usecases/cancel_transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFinanceRepository extends Mock implements FinanceRepository {}

class MockReceiptRepository extends Mock implements ReceiptRepository {}

void main() {
  late MockFinanceRepository financeRepository;
  late MockReceiptRepository receiptRepository;
  late CancelTransaction cancelTransaction;

  final cancelledTx = FinancialTransaction(
    id: 'tx-1',
    churchId: 'church-1',
    type: TransactionType.offrande,
    amountCents: 5000,
    transactionDate: DateTime(2026, 9, 13),
    isCancelled: true,
    cancelledReason: 'Erreur de saisie',
  );

  setUp(() {
    financeRepository = MockFinanceRepository();
    receiptRepository = MockReceiptRepository();
    cancelTransaction = CancelTransaction(
      financeRepository: financeRepository,
      receiptRepository: receiptRepository,
    );
  });

  group('CancelTransaction', () {
    test('rejette un motif vide sans appeler les repositories', () async {
      final result = await cancelTransaction(
        transactionId: 'tx-1',
        reason: '   ',
      );

      expect(result, isA<Error<FinancialTransaction>>());
      verifyNever(() => financeRepository.cancelTransaction(
            id: any(named: 'id'),
            reason: any(named: 'reason'),
          ));
    });

    test('propage l\'échec du repository sans tenter d\'annuler le reçu',
        () async {
      when(() => financeRepository.cancelTransaction(
            id: 'tx-1',
            reason: 'Erreur de saisie',
          )).thenAnswer(
        (_) async => const Error(NotFoundFailure('introuvable')),
      );

      final result = await cancelTransaction(
        transactionId: 'tx-1',
        reason: 'Erreur de saisie',
      );

      expect(result, isA<Error<FinancialTransaction>>());
      verifyNever(() => receiptRepository.cancelReceiptForTransaction(any()));
    });

    test('cas nominal : annule la transaction ET le reçu associé', () async {
      when(() => financeRepository.cancelTransaction(
            id: 'tx-1',
            reason: 'Erreur de saisie',
          )).thenAnswer((_) async => Success(cancelledTx));
      when(() => receiptRepository.cancelReceiptForTransaction('tx-1'))
          .thenAnswer((_) async => const Success(null));

      final result = await cancelTransaction(
        transactionId: 'tx-1',
        reason: 'Erreur de saisie',
      );

      expect(result, isA<Success<FinancialTransaction>>());
      verify(() => receiptRepository.cancelReceiptForTransaction('tx-1'))
          .called(1);
    });
  });
}
