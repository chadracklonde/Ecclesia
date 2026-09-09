import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../datasources/local_receipt_counter_datasource.dart';
import '../datasources/local_receipt_datasource.dart';
import '../models/finance_model.dart';

class ReceiptRepositoryImpl implements ReceiptRepository {
  final LocalReceiptDataSource dataSource;
  final LocalReceiptCounterDataSource counterDataSource;
  final Uuid uuid;

  ReceiptRepositoryImpl({
    required this.dataSource,
    required this.counterDataSource,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  @override
  Future<Result<Receipt>> issueReceipt({
    required String churchId,
    required String transactionId,
    String? issuedBy,
  }) async {
    try {
      final existing = await dataSource.getForTransaction(transactionId);
      if (existing != null) {
        return Success(existing.toDomain());
      }

      final now = DateTime.now();
      final number =
          await counterDataSource.nextNumber(churchId: churchId, year: now.year);
      final receiptNumber = 'REC-${now.year}-${number.toString().padLeft(6, '0')}';

      final receipt = Receipt(
        id: uuid.v4(),
        transactionId: transactionId,
        receiptNumber: receiptNumber,
        issueDate: now,
        issuedBy: issuedBy,
      );
      await dataSource.insert(receipt.toCompanion());
      return Success(receipt);
    } catch (e) {
      return Error(DatabaseFailure('Échec de la génération du reçu : $e'));
    }
  }

  @override
  Future<Result<Receipt>> getReceiptForTransaction(String transactionId) async {
    try {
      final row = await dataSource.getForTransaction(transactionId);
      if (row == null) {
        return const Error(NotFoundFailure('Reçu introuvable'));
      }
      return Success(row.toDomain());
    } catch (e) {
      return Error(DatabaseFailure('Échec de la lecture du reçu : $e'));
    }
  }

  @override
  Future<Result<void>> cancelReceiptForTransaction(String transactionId) async {
    try {
      final row = await dataSource.getForTransaction(transactionId);
      if (row == null) {
        // Pas de reçu associé (ex. dépense) — rien à annuler, pas une erreur.
        return const Success(null);
      }
      await dataSource.cancel(row.id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Échec de l\'annulation du reçu : $e'));
    }
  }
}
