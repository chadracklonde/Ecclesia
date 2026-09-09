import '../../../../core/utils/result.dart';
import '../entities/role.dart';
import '../repositories/role_repository.dart';

class HasPermission {
  final PermissionRepository repository;

  HasPermission(this.repository);

  Future<Result<bool>> call({
    required String roleId,
    required PermissionModule module,
    required PermissionAction action,
  }) async {
    final result = await repository.getPermissionsForRole(roleId);
    if (result is Error<List<Permission>>) {
      return Error(result.failure);
    }
    final permissions = (result as Success<List<Permission>>).value;
    final allowed =
        permissions.any((p) => p.module == module && p.action == action);
    return Success(allowed);
  }
}
