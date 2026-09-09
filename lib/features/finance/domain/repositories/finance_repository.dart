import '../../../../core/utils/result.dart';
import '../entities/financial_transaction.dart';

abstract class FinanceRepository {
  Future<Result<FinancialTransaction>> createTransaction(
    FinancialTransaction transaction,
  );

  Future<Result<FinancialTransaction>> getTransactionById(String id);

  Future<Result<List<FinancialTransaction>>> getTransactionsForChurch({
    required String churchId,
    DateTime? from,
    DateTime? to,
  });

  Future<Result<FinancialTransaction>> cancelTransaction({
    required String id,
    required String reason,
  });

  /// Solde calculé par agrégation des transactions actives — jamais un
  /// champ stocké mutable. Élimine par construction tout risque de
  /// "transaction flottante" (critère d'audit explicite de l'Étape 1).
  Future<Result<int>> getCashBalanceCents({required String churchId});
}
