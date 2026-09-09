import '../../../../core/utils/result.dart';
import '../entities/receipt.dart';

abstract class ReceiptRepository {
  /// Idempotent : si un reçu existe déjà pour cette transaction, il est
  /// retourné tel quel plutôt que d'en générer un second (évite de
  /// consommer deux numéros pour la même transaction en cas de double-clic
  /// ou de nouvelle tentative après erreur réseau future).
  Future<Result<Receipt>> issueReceipt({
    required String churchId,
    required String transactionId,
    String? issuedBy,
  });

  Future<Result<Receipt>> getReceiptForTransaction(String transactionId);

  Future<Result<void>> cancelReceiptForTransaction(String transactionId);
}
