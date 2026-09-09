import 'package:equatable/equatable.dart';

enum TransactionType { dime, offrande, quete, depense }

/// Montant en `amountCents` (entier, plus petite unité monétaire) —
/// jamais de `double` pour de l'argent : évite les erreurs d'arrondi
/// silencieuses (cf. Étape 1 §2bis, exigence spécifique au module
/// Finances).
class FinancialTransaction extends Equatable {
  final String id;
  final String churchId;
  final TransactionType type;
  final int amountCents;
  final String currency;
  final DateTime transactionDate;
  final String? memberId;
  final String? serviceId;
  final String? category;
  final String? note;
  final String? recordedBy;
  final bool isCancelled;
  final DateTime? cancelledAt;
  final String? cancelledReason;

  const FinancialTransaction({
    required this.id,
    required this.churchId,
    required this.type,
    required this.amountCents,
    this.currency = 'CDF',
    required this.transactionDate,
    this.memberId,
    this.serviceId,
    this.category,
    this.note,
    this.recordedBy,
    this.isCancelled = false,
    this.cancelledAt,
    this.cancelledReason,
  });

  bool get isIncome => type != TransactionType.depense;

  @override
  List<Object?> get props => [
        id,
        churchId,
        type,
        amountCents,
        currency,
        transactionDate,
        memberId,
        serviceId,
        category,
        note,
        recordedBy,
        isCancelled,
        cancelledAt,
        cancelledReason,
      ];
}
