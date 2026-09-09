import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/financial_transaction.dart';
import '../entities/receipt.dart';
import '../repositories/finance_repository.dart';
import '../repositories/receipt_repository.dart';

typedef IncomeRecordResult = ({
  FinancialTransaction transaction,
  Receipt receipt,
});

/// Traite les revenus (dîme/offrande/quête) : validation, création de la
/// transaction, puis génération automatique du reçu. Les dépenses passent
/// par `RecordExpenseTransaction`, qui ne génère pas de reçu.
class RecordIncomeTransaction {
  final FinanceRepository financeRepository;
  final ReceiptRepository receiptRepository;
  final Uuid uuid;

  RecordIncomeTransaction({
    required this.financeRepository,
    required this.receiptRepository,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  Future<Result<IncomeRecordResult>> call({
    required String churchId,
    required TransactionType type,
    required int amountCents,
    String? memberId,
    String? note,
    String? recordedBy,
    DateTime? date,
  }) async {
    if (type == TransactionType.depense) {
      return const Error(
          ValidationFailure('Ce usecase ne traite pas les dépenses'));
    }
    if (amountCents <= 0) {
      return const Error(
          ValidationFailure('Le montant doit être supérieur à zéro'));
    }

    final transaction = FinancialTransaction(
      id: uuid.v4(),
      churchId: churchId,
      type: type,
      amountCents: amountCents,
      transactionDate: date ?? DateTime.now(),
      memberId: memberId,
      note: note,
      recordedBy: recordedBy,
    );

    final transactionResult = await financeRepository.createTransaction(transaction);
    if (transactionResult is Error<FinancialTransaction>) {
      return Error(transactionResult.failure);
    }
    final savedTransaction =
        (transactionResult as Success<FinancialTransaction>).value;

    final receiptResult = await receiptRepository.issueReceipt(
      churchId: churchId,
      transactionId: savedTransaction.id,
      issuedBy: recordedBy,
    );
    if (receiptResult is Error<Receipt>) {
      return Error(receiptResult.failure);
    }
    final receipt = (receiptResult as Success<Receipt>).value;

    return Success((transaction: savedTransaction, receipt: receipt));
  }
}
