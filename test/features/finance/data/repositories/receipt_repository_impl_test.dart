import 'package:drift/native.dart';
import 'package:ecclesia/core/database/database.dart';
import 'package:ecclesia/core/utils/result.dart';
import 'package:ecclesia/features/finance/data/datasources/local_finance_datasource.dart';
import 'package:ecclesia/features/finance/data/datasources/local_receipt_counter_datasource.dart';
import 'package:ecclesia/features/finance/data/datasources/local_receipt_datasource.dart';
import 'package:ecclesia/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:ecclesia/features/finance/data/repositories/receipt_repository_impl.dart';
import 'package:ecclesia/features/finance/domain/entities/financial_transaction.dart';
import 'package:ecclesia/features/finance/domain/entities/receipt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ReceiptRepositoryImpl receiptRepository;
  late FinanceRepositoryImpl financeRepository;

  const churchId = 'church-1';

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.into(db.churches).insert(
        ChurchesCompanion.insert(id: churchId, code: 'RTC', name: 'RTC-MALI'));
    financeRepository = FinanceRepositoryImpl(LocalFinanceDataSource(db));
    receiptRepository = ReceiptRepositoryImpl(
      dataSource: LocalReceiptDataSource(db),
      counterDataSource: LocalReceiptCounterDataSource(db),
    );
    await financeRepository.createTransaction(FinancialTransaction(
      id: 'tx-1',
      churchId: churchId,
      type: TransactionType.dime,
      amountCents: 5000,
      transactionDate: DateTime(2026, 9, 13),
    ));
    await financeRepository.createTransaction(FinancialTransaction(
      id: 'tx-2',
      churchId: churchId,
      type: TransactionType.offrande,
      amountCents: 3000,
      transactionDate: DateTime(2026, 9, 13),
    ));
  });

  tearDown(() async {
    await db.close();
  });

  String unwrapReceiptNumber(Result<Receipt> result) {
    return result.fold(
      (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
      (receipt) => receipt.receiptNumber,
    );
  }

  group('ReceiptRepositoryImpl', () {
    test(
        'génère des numéros séquentiels croissants au sein de la même église/année',
        () async {
      final r1 = await receiptRepository.issueReceipt(
          churchId: churchId, transactionId: 'tx-1');
      final r2 = await receiptRepository.issueReceipt(
          churchId: churchId, transactionId: 'tx-2');

      final n1 = unwrapReceiptNumber(r1);
      final n2 = unwrapReceiptNumber(r2);
      expect(n1, isNot(equals(n2)));

      final seq1 = int.parse(n1.split('-').last);
      final seq2 = int.parse(n2.split('-').last);
      expect(seq2, seq1 + 1);
    });

    test(
        'émettre un reçu deux fois pour la même transaction est idempotent '
        '(pas de second numéro consommé)', () async {
      final first = await receiptRepository.issueReceipt(
          churchId: churchId, transactionId: 'tx-1');
      final second = await receiptRepository.issueReceipt(
          churchId: churchId, transactionId: 'tx-1');

      expect(unwrapReceiptNumber(first), unwrapReceiptNumber(second));
    });

    test('cancelReceiptForTransaction marque le reçu annulé sans le supprimer',
        () async {
      await receiptRepository.issueReceipt(
          churchId: churchId, transactionId: 'tx-1');
      await receiptRepository.cancelReceiptForTransaction('tx-1');

      final result = await receiptRepository.getReceiptForTransaction('tx-1');
      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (receipt) => expect(receipt.isCancelled, isTrue),
      );
    });
  });
}
