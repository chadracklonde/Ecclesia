import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/user_account.dart';

String roleNameToString(RoleName name) {
  switch (name) {
    case RoleName.superAdmin:
      return 'super_admin';
    case RoleName.pasteur:
      return 'pasteur';
    case RoleName.tresorier:
      return 'tresorier';
    case RoleName.secretaire:
      return 'secretaire';
    case RoleName.responsableClasse:
      return 'responsable_classe';
    case RoleName.membreLecture:
      return 'membre_lecture';
  }
}

RoleName roleNameFromString(String value) {
  switch (value) {
    case 'super_admin':
      return RoleName.superAdmin;
    case 'pasteur':
      return RoleName.pasteur;
    case 'tresorier':
      return RoleName.tresorier;
    case 'secretaire':
      return RoleName.secretaire;
    case 'responsable_classe':
      return RoleName.responsableClasse;
    default:
      return RoleName.membreLecture;
  }
}

String permissionModuleToString(PermissionModule module) {
  switch (module) {
    case PermissionModule.members:
      return 'members';
    case PermissionModule.finance:
      return 'finance';
    case PermissionModule.attendance:
      return 'attendance';
    case PermissionModule.liturgy:
      return 'liturgy';
    case PermissionModule.secretariat:
      return 'secretariat';
    case PermissionModule.admin:
      return 'admin';
    case PermissionModule.classesSubgroups:
      return 'classes_subgroups';
  }
}

PermissionModule permissionModuleFromString(String value) {
  switch (value) {
    case 'finance':
      return PermissionModule.finance;
    case 'attendance':
      return PermissionModule.attendance;
    case 'liturgy':
      return PermissionModule.liturgy;
    case 'secretariat':
      return PermissionModule.secretariat;
    case 'admin':
      return PermissionModule.admin;
    case 'classes_subgroups':
      return PermissionModule.classesSubgroups;
    default:
      return PermissionModule.members;
  }
}

String permissionActionToString(PermissionAction action) {
  switch (action) {
    case PermissionAction.create:
      return 'create';
    case PermissionAction.read:
      return 'read';
    case PermissionAction.update:
      return 'update';
    case PermissionAction.delete:
      return 'delete';
  }
}

PermissionAction permissionActionFromString(String value) {
  switch (value) {
    case 'read':
      return PermissionAction.read;
    case 'update':
      return PermissionAction.update;
    case 'delete':
      return PermissionAction.delete;
    default:
      return PermissionAction.create;
  }
}

extension RoleRowMapper on RoleRow {
  Role toDomain() {
    return Role(id: id, churchId: churchId, name: roleNameFromString(name));
  }
}

extension RoleDomainMapper on Role {
  RolesCompanion toCompanion() {
    return RolesCompanion.insert(
      id: id,
      churchId: churchId,
      name: roleNameToString(name),
    );
  }
}

extension PermissionRowMapper on PermissionRow {
  Permission toDomain() {
    return Permission(
      id: id,
      roleId: roleId,
      module: permissionModuleFromString(module),
      action: permissionActionFromString(action),
    );
  }
}

extension PermissionDomainMapper on Permission {
  PermissionsCompanion toCompanion() {
    return PermissionsCompanion.insert(
      id: id,
      roleId: roleId,
      module: permissionModuleToString(module),
      action: permissionActionToString(action),
    );
  }
}

extension UserAccountRowMapper on UserAccountRow {
  UserAccount toDomain() {
    return UserAccount(
      id: id,
      churchId: churchId,
      username: username,
      memberId: memberId,
      roleId: roleId,
      isActive: isActive,
    );
  }
}

extension UserAccountDomainMapper on UserAccount {
  UserAccountsCompanion toCompanion({
    required String passwordHash,
    required String passwordSalt,
  }) {
    return UserAccountsCompanion.insert(
      id: id,
      churchId: churchId,
      username: username,
      passwordHash: passwordHash,
      passwordSalt: passwordSalt,
      memberId: Value(memberId),
      roleId: roleId,
      isActive: Value(isActive),
    );
  }
}
