import 'package:equatable/equatable.dart';

/// Les 6 rôles validés dans la matrice de permissions de l'Étape 0.
enum RoleName {
  superAdmin,
  pasteur,
  tresorier,
  secretaire,
  responsableClasse,
  membreLecture,
}

enum PermissionModule {
  members,
  finance,
  attendance,
  liturgy,
  secretariat,
  admin,
  classesSubgroups,
}

enum PermissionAction { create, read, update, delete }

class Role extends Equatable {
  final String id;
  final String churchId;
  final RoleName name;

  const Role({required this.id, required this.churchId, required this.name});

  @override
  List<Object?> get props => [id, churchId, name];
}

class Permission extends Equatable {
  final String id;
  final String roleId;
  final PermissionModule module;
  final PermissionAction action;

  const Permission({
    required this.id,
    required this.roleId,
    required this.module,
    required this.action,
  });

  @override
  List<Object?> get props => [id, roleId, module, action];
}
