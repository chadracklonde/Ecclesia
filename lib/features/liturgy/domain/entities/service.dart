import 'package:equatable/equatable.dart';

enum ServiceType { dominical, special, veillee }

enum ServiceStatus { planned, held, cancelled }

class Service extends Equatable {
  final String id;
  final String churchId;
  final DateTime date;
  final ServiceType type;
  final String? theme;
  final ServiceStatus status;

  const Service({
    required this.id,
    required this.churchId,
    required this.date,
    required this.type,
    this.theme,
    this.status = ServiceStatus.planned,
  });

  @override
  List<Object?> get props => [id, churchId, date, type, theme, status];
}
