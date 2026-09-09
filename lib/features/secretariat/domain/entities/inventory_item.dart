import 'package:equatable/equatable.dart';

class InventoryItem extends Equatable {
  final String id;
  final String churchId;
  final String name;
  final String? category;
  final int quantity;
  final String? condition;
  final String? location;
  final DateTime? acquiredDate;

  const InventoryItem({
    required this.id,
    required this.churchId,
    required this.name,
    this.category,
    this.quantity = 1,
    this.condition,
    this.location,
    this.acquiredDate,
  });

  @override
  List<Object?> get props =>
      [id, churchId, name, category, quantity, condition, location, acquiredDate];
}
