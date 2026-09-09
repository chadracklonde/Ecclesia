import 'package:equatable/equatable.dart';

/// Nommée `ChurchClass` (pas `Class`) pour éviter toute confusion avec le
/// mot-clé Dart `class` — cohérent avec le nom de table `ChurchClasses`.
class ChurchClass extends Equatable {
  final String id;
  final String churchId;
  final String name;
  final String? leaderMemberId;
  final String? description;

  const ChurchClass({
    required this.id,
    required this.churchId,
    required this.name,
    this.leaderMemberId,
    this.description,
  });

  @override
  List<Object?> get props => [id, churchId, name, leaderMemberId, description];
}
