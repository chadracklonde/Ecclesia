import 'package:equatable/equatable.dart';

class Subgroup extends Equatable {
  final String id;
  final String churchId;
  final String name;
  final String type;
  final String? leaderMemberId;

  const Subgroup({
    required this.id,
    required this.churchId,
    required this.name,
    required this.type,
    this.leaderMemberId,
  });

  @override
  List<Object?> get props => [id, churchId, name, type, leaderMemberId];
}
