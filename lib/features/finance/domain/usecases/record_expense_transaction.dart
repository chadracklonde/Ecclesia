import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/financial_transaction.dart';
import '../repositories/finance_repository.dart';

class RecordExpenseTransaction {
  final FinanceRepository financeRepository;
  final Uuid uuid;

  RecordExpenseTransaction({required this.financeRepository, Uuid? uuid})
      : uuid = uuid ?? const Uuid();

  Future<Result<FinancialTransaction>> call({
    required String churchId,
    required int amountCents,
    required String category,
    String? note,
    String? recordedBy,
    DateTime? date,
  }) async {
    if (amountCents <= 0) {
      return const Error(
          ValidationFailure('Le montant doit être supérieur à zéro'));
    }
    if (category.trim().isEmpty) {
      return const Error(
          ValidationFailure('La catégorie de dépense est obligatoire'));
    }

    final transaction = FinancialTransaction(
      id: uuid.v4(),
      churchId: churchId,
      type: TransactionType.depense,
      amountCents: amountCents,
      transactionDate: date ?? DateTime.now(),
      category: category.trim(),
      note: note,
      recordedBy: recordedBy,
    );

    return financeRepository.createTransaction(transaction);
  }
}
