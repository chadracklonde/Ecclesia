import '../../../../core/utils/result.dart';
import '../entities/role.dart';

abstract class RoleRepository {
  Future<Result<Role>> createRole(Role role);

  Future<Result<List<Role>>> getRolesForChurch({required String churchId});

  Future<Result<Role>> getRoleById(String id);
}

abstract class PermissionRepository {
  /// Remplace intégralement les permissions d'un rôle par la liste donnée
  /// (utilisé pour l'amorçage de la matrice de l'Étape 0).
  Future<Result<void>> setPermissions(String roleId, List<Permission> permissions);

  Future<Result<List<Permission>>> getPermissionsForRole(String roleId);
}
