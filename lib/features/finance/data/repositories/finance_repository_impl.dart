import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/financial_transaction.dart';
import '../../domain/repositories/finance_repository.dart';
import '../datasources/local_finance_datasource.dart';
import '../models/finance_model.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final LocalFinanceDataSource dataSource;

  FinanceRepositoryImpl(this.dataSource);

  @override
  Future<Result<FinancialTransaction>> createTransaction(
    FinancialTransaction transaction,
  ) async {
    try {
      await dataSource.insert(transaction.toCompanion());
      return Success(transaction);
    } catch (e) {
      return Error(
          DatabaseFailure('Échec de l\'enregistrement de la transaction : $e'));
    }
  }

  @override
  Future<Result<FinancialTransaction>> getTransactionById(String id) async {
    try {
      final row = await dataSource.getById(id);
      if (row == null) {
        return const Error(NotFoundFailure('Transaction introuvable'));
      }
      return Success(row.toDomain());
    } catch (e) {
      return Error(
          DatabaseFailure('Échec de la lecture de la transaction : $e'));
    }
  }

  @override
  Future<Result<List<FinancialTransaction>>> getTransactionsForChurch({
    required String churchId,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final rows =
          await dataSource.getForChurch(churchId: churchId, from: from, to: to);
      return Success(rows.map((r) => r.toDomain()).toList());
    } catch (e) {
      return Error(DatabaseFailure('Échec de la lecture des transactions : $e'));
    }
  }

  @override
  Future<Result<FinancialTransaction>> cancelTransaction({
    required String id,
    required String reason,
  }) async {
    try {
      final existing = await dataSource.getById(id);
      if (existing == null) {
        return const Error(NotFoundFailure('Transaction introuvable'));
      }
      if (existing.isCancelled) {
        return const Error(
            ValidationFailure('Cette transaction est déjà annulée'));
      }
      await dataSource.updateCancellation(
        id,
        cancelledAt: DateTime.now(),
        reason: reason,
      );
      final updated = await dataSource.getById(id);
      return Success(updated!.toDomain());
    } catch (e) {
      return Error(
          DatabaseFailure('Échec de l\'annulation de la transaction : $e'));
    }
  }

  @override
  Future<Result<int>> getCashBalanceCents({required String churchId}) async {
    try {
      final income = await dataSource.sumActiveIncomeCents(churchId);
      final expense = await dataSource.sumActiveExpenseCents(churchId);
      return Success(income - expense);
    } catch (e) {
      return Error(DatabaseFailure('Échec du calcul du solde : $e'));
    }
  }
}
