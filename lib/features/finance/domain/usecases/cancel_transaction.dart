import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/financial_transaction.dart';
import '../repositories/finance_repository.dart';
import '../repositories/receipt_repository.dart';

class CancelTransaction {
  final FinanceRepository financeRepository;
  final ReceiptRepository receiptRepository;

  CancelTransaction({
    required this.financeRepository,
    required this.receiptRepository,
  });

  /// LIMITE ASSUMÉE, PAS CACHÉE : l'annulation de la transaction et celle
  /// du reçu associé ne sont PAS atomiques à ce niveau — deux repositories
  /// distincts, pas de transaction DB partagée à cette couche
  /// d'abstraction. Un crash entre les deux appels laisserait un état
  /// incohérent (l'un annulé, l'autre pas). Acceptable vu la fréquence
  /// attendue très faible des annulations ; à durcir si ça devient
  /// sensible (ex. combiner les deux opérations dans un seul repository
  /// avec une transaction `drift` explicite).
  Future<Result<FinancialTransaction>> call({
    required String transactionId,
    required String reason,
  }) async {
    if (reason.trim().isEmpty) {
      return const Error(
          ValidationFailure('Un motif d\'annulation est obligatoire'));
    }

    final result = await financeRepository.cancelTransaction(
      id: transactionId,
      reason: reason.trim(),
    );
    if (result is Error<FinancialTransaction>) {
      return result;
    }

    await receiptRepository.cancelReceiptForTransaction(transactionId);
    return result;
  }
}
