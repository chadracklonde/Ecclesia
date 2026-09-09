import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/financial_transaction.dart';
import 'finance_providers.dart';

final cashBalanceProvider =
    FutureProvider.family<int, String>((ref, churchId) async {
  final getCashBalance = ref.watch(getCashBalanceUseCaseProvider);
  final result = await getCashBalance(churchId: churchId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (cents) => cents,
  );
});

final transactionsListProvider =
    FutureProvider.family<List<FinancialTransaction>, String>((ref, churchId) async {
  final listTransactions = ref.watch(listTransactionsUseCaseProvider);
  final result = await listTransactions(churchId: churchId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (transactions) => transactions,
  );
});
