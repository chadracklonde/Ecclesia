import 'package:equatable/equatable.dart';

enum PreacherRole { principal, invite }

/// `memberId` nullable — un prédicateur externe (invité) n'est pas
/// nécessairement un membre enregistré (Étape 0, décision #2).
class PreacherAssignment extends Equatable {
  final String id;
  final String serviceId;
  final String? memberId;
  final String? externalName;
  final String? externalContact;
  final PreacherRole role;

  const PreacherAssignment({
    required this.id,
    required this.serviceId,
    this.memberId,
    this.externalName,
    this.externalContact,
    this.role = PreacherRole.principal,
  });

  bool get isExternal => memberId == null;

  @override
  List<Object?> get props =>
      [id, serviceId, memberId, externalName, externalContact, role];
}
