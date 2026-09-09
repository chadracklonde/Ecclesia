import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../domain/entities/financial_transaction.dart';
import '../../domain/entities/receipt.dart';

String transactionTypeToString(TransactionType type) {
  switch (type) {
    case TransactionType.dime:
      return 'dime';
    case TransactionType.offrande:
      return 'offrande';
    case TransactionType.quete:
      return 'quete';
    case TransactionType.depense:
      return 'depense';
  }
}

TransactionType transactionTypeFromString(String value) {
  switch (value) {
    case 'dime':
      return TransactionType.dime;
    case 'offrande':
      return TransactionType.offrande;
    case 'quete':
      return TransactionType.quete;
    default:
      return TransactionType.depense;
  }
}

extension FinancialTransactionRowMapper on FinancialTransactionRow {
  FinancialTransaction toDomain() {
    return FinancialTransaction(
      id: id,
      churchId: churchId,
      type: transactionTypeFromString(type),
      amountCents: amountCents,
      currency: currency,
      transactionDate: transactionDate,
      memberId: memberId,
      serviceId: serviceId,
      category: category,
      note: note,
      recordedBy: recordedBy,
      isCancelled: isCancelled,
      cancelledAt: cancelledAt,
      cancelledReason: cancelledReason,
    );
  }
}

extension FinancialTransactionDomainMapper on FinancialTransaction {
  FinancialTransactionsCompanion toCompanion() {
    return FinancialTransactionsCompanion.insert(
      id: id,
      churchId: churchId,
      type: transactionTypeToString(type),
      amountCents: amountCents,
      currency: Value(currency),
      transactionDate: transactionDate,
      memberId: Value(memberId),
      serviceId: Value(serviceId),
      category: Value(category),
      note: Value(note),
      recordedBy: Value(recordedBy),
    );
  }
}

extension ReceiptRowMapper on ReceiptRow {
  Receipt toDomain() {
    return Receipt(
      id: id,
      transactionId: transactionId,
      receiptNumber: receiptNumber,
      issueDate: issueDate,
      issuedBy: issuedBy,
      isCancelled: isCancelled,
    );
  }
}

extension ReceiptDomainMapper on Receipt {
  ReceiptsCompanion toCompanion() {
    return ReceiptsCompanion.insert(
      id: id,
      transactionId: transactionId,
      receiptNumber: receiptNumber,
      issueDate: Value(issueDate),
      issuedBy: Value(issuedBy),
    );
  }
}
