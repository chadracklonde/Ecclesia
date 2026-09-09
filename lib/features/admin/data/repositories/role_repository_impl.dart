import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/role.dart';
import '../../domain/repositories/role_repository.dart';
import '../datasources/local_role_datasource.dart';
import '../models/admin_model.dart';

class RoleRepositoryImpl implements RoleRepository {
  final LocalRoleDataSource dataSource;

  RoleRepositoryImpl(this.dataSource);

  @override
  Future<Result<Role>> createRole(Role role) async {
    try {
      await dataSource.insertRole(role.toCompanion());
      return Success(role);
    } catch (e) {
      return Error(DatabaseFailure('Échec de la création du rôle : $e'));
    }
  }

  @override
  Future<Result<List<Role>>> getRolesForChurch({required String churchId}) async {
    try {
      final rows = await dataSource.getForChurch(churchId);
      return Success(rows.map((r) => r.toDomain()).toList());
    } catch (e) {
      return Error(DatabaseFailure('Échec de la lecture des rôles : $e'));
    }
  }

  @override
  Future<Result<Role>> getRoleById(String id) async {
    try {
      final row = await dataSource.getById(id);
      if (row == null) {
        return const Error(NotFoundFailure('Rôle introuvable'));
      }
      return Success(row.toDomain());
    } catch (e) {
      return Error(DatabaseFailure('Échec de la lecture du rôle : $e'));
    }
  }
}

class PermissionRepositoryImpl implements PermissionRepository {
  final LocalPermissionDataSource dataSource;

  PermissionRepositoryImpl(this.dataSource);

  @override
  Future<Result<void>> setPermissions(
    String roleId,
    List<Permission> permissions,
  ) async {
    try {
      await dataSource.deleteForRole(roleId);
      for (final permission in permissions) {
        await dataSource.insertPermission(permission.toCompanion());
      }
      return const Success(null);
    } catch (e) {
      return Error(
          DatabaseFailure('Échec de l\'enregistrement des permissions : $e'));
    }
  }

  @override
  Future<Result<List<Permission>>> getPermissionsForRole(String roleId) async {
    try {
      final rows = await dataSource.getForRole(roleId);
      return Success(rows.map((r) => r.toDomain()).toList());
    } catch (e) {
      return Error(DatabaseFailure('Échec de la lecture des permissions : $e'));
    }
  }
}
