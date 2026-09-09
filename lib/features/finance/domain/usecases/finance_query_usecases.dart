import '../../../../core/utils/result.dart';
import '../entities/financial_transaction.dart';
import '../repositories/finance_repository.dart';

class GetCashBalance {
  final FinanceRepository repository;

  GetCashBalance(this.repository);

  Future<Result<int>> call({required String churchId}) {
    return repository.getCashBalanceCents(churchId: churchId);
  }
}

class ListTransactions {
  final FinanceRepository repository;

  ListTransactions(this.repository);

  Future<Result<List<FinancialTransaction>>> call({
    required String churchId,
    DateTime? from,
    DateTime? to,
  }) {
    return repository.getTransactionsForChurch(
      churchId: churchId,
      from: from,
      to: to,
    );
  }
}
