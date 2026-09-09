import '../../../../core/database/database.dart';

class LocalRoleDataSource {
  final AppDatabase db;

  LocalRoleDataSource(this.db);

  Future<void> insertRole(RolesCompanion companion) {
    return db.into(db.roles).insert(companion);
  }

  Future<RoleRow?> getById(String id) {
    return (db.select(db.roles)..where((r) => r.id.equals(id))).getSingleOrNull();
  }

  Future<List<RoleRow>> getForChurch(String churchId) {
    return (db.select(db.roles)..where((r) => r.churchId.equals(churchId))).get();
  }
}

class LocalPermissionDataSource {
  final AppDatabase db;

  LocalPermissionDataSource(this.db);

  Future<void> insertPermission(PermissionsCompanion companion) {
    return db.into(db.permissions).insert(companion);
  }

  Future<void> deleteForRole(String roleId) {
    return (db.delete(db.permissions)..where((p) => p.roleId.equals(roleId))).go();
  }

  Future<List<PermissionRow>> getForRole(String roleId) {
    return (db.select(db.permissions)..where((p) => p.roleId.equals(roleId))).get();
  }
}
