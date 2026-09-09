import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/datasources/local_finance_datasource.dart';
import '../../data/datasources/local_receipt_counter_datasource.dart';
import '../../data/datasources/local_receipt_datasource.dart';
import '../../data/repositories/finance_repository_impl.dart';
import '../../data/repositories/receipt_repository_impl.dart';
import '../../domain/repositories/finance_repository.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../../domain/usecases/cancel_transaction.dart';
import '../../domain/usecases/finance_query_usecases.dart';
import '../../domain/usecases/record_expense_transaction.dart';
import '../../domain/usecases/record_income_transaction.dart';

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return FinanceRepositoryImpl(LocalFinanceDataSource(db));
});

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ReceiptRepositoryImpl(
    dataSource: LocalReceiptDataSource(db),
    counterDataSource: LocalReceiptCounterDataSource(db),
  );
});

final recordIncomeTransactionProvider = Provider<RecordIncomeTransaction>((ref) {
  return RecordIncomeTransaction(
    financeRepository: ref.watch(financeRepositoryProvider),
    receiptRepository: ref.watch(receiptRepositoryProvider),
  );
});

final recordExpenseTransactionProvider = Provider<RecordExpenseTransaction>((ref) {
  return RecordExpenseTransaction(
    financeRepository: ref.watch(financeRepositoryProvider),
  );
});

final cancelTransactionProvider = Provider<CancelTransaction>((ref) {
  return CancelTransaction(
    financeRepository: ref.watch(financeRepositoryProvider),
    receiptRepository: ref.watch(receiptRepositoryProvider),
  );
});

final getCashBalanceUseCaseProvider = Provider<GetCashBalance>((ref) {
  return GetCashBalance(ref.watch(financeRepositoryProvider));
});

final listTransactionsUseCaseProvider = Provider<ListTransactions>((ref) {
  return ListTransactions(ref.watch(financeRepositoryProvider));
});
