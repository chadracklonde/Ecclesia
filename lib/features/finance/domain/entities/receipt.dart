import 'package:equatable/equatable.dart';

class Receipt extends Equatable {
  final String id;
  final String transactionId;
  final String receiptNumber;
  final DateTime issueDate;
  final String? issuedBy;
  final bool isCancelled;

  const Receipt({
    required this.id,
    required this.transactionId,
    required this.receiptNumber,
    required this.issueDate,
    this.issuedBy,
    this.isCancelled = false,
  });

  @override
  List<Object?> get props =>
      [id, transactionId, receiptNumber, issueDate, issuedBy, isCancelled];
}
