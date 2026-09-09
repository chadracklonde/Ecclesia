import 'package:uuid/uuid.dart';

import '../../../../core/utils/result.dart';
import '../entities/role.dart';
import '../repositories/role_repository.dart';

/// Amorce les 6 rôles et leur matrice de permissions validée à l'Étape 0.
///
/// LIMITE ASSUMÉE ET DOCUMENTÉE : la matrice originale qualifiait certains
/// droits de "sa classe" (Responsable de classe) ou "sa fiche" (Membre) —
/// une portée au niveau de la ligne, pas seulement du module. Cette
/// implémentation ne gère que des permissions au niveau du module
/// (CRUD/Lecture/aucun accès), pas ce filtrage fin par enregistrement.
/// Cette portée réduite est un choix conscient pour cette itération, pas
/// un oubli — à durcir si le besoin réel l'exige.
class SeedDefaultRolesAndPermissions {
  final RoleRepository roleRepository;
  final PermissionRepository permissionRepository;
  final Uuid uuid;

  SeedDefaultRolesAndPermissions({
    required this.roleRepository,
    required this.permissionRepository,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  Future<Result<void>> call({required String churchId}) async {
    for (final entry in _matrix.entries) {
      final roleId = uuid.v4();
      final roleResult = await roleRepository.createRole(
        Role(id: roleId, churchId: churchId, name: entry.key),
      );
      if (roleResult is Error<Role>) {
        return Error(roleResult.failure);
      }

      final permissions = entry.value
          .map((moduleAction) => Permission(
                id: uuid.v4(),
                roleId: roleId,
                module: moduleAction.$1,
                action: moduleAction.$2,
              ))
          .toList();

      final permResult =
          await permissionRepository.setPermissions(roleId, permissions);
      if (permResult is Error<void>) {
        return permResult;
      }
    }
    return const Success(null);
  }

  static const _crud = [
    PermissionAction.create,
    PermissionAction.read,
    PermissionAction.update,
    PermissionAction.delete,
  ];
  static const _readOnly = [PermissionAction.read];

  /// Matrice de l'Étape 0 (section 4), traduite au niveau module.
  static final Map<RoleName, List<(PermissionModule, PermissionAction)>> _matrix = {
    RoleName.superAdmin: [
      for (final m in PermissionModule.values)
        for (final a in _crud) (m, a),
    ],
    RoleName.pasteur: [
      for (final a in _crud) (PermissionModule.members, a),
      for (final a in _readOnly) (PermissionModule.finance, a),
      for (final a in _crud) (PermissionModule.attendance, a),
      for (final a in _crud) (PermissionModule.liturgy, a),
      for (final a in _readOnly) (PermissionModule.secretariat, a),
      for (final a in _readOnly) (PermissionModule.admin, a),
    ],
    RoleName.tresorier: [
      for (final a in _readOnly) (PermissionModule.members, a),
      for (final a in _crud) (PermissionModule.finance, a),
      for (final a in _readOnly) (PermissionModule.liturgy, a),
    ],
    RoleName.secretaire: [
      for (final a in _crud) (PermissionModule.members, a),
      for (final a in _readOnly) (PermissionModule.finance, a),
      for (final a in _readOnly) (PermissionModule.attendance, a),
      for (final a in _crud) (PermissionModule.liturgy, a),
      for (final a in _crud) (PermissionModule.secretariat, a),
    ],
    RoleName.responsableClasse: [
      for (final a in _readOnly) (PermissionModule.members, a),
      for (final a in _crud) (PermissionModule.attendance, a),
      for (final a in _readOnly) (PermissionModule.liturgy, a),
    ],
    RoleName.membreLecture: [
      for (final a in _readOnly) (PermissionModule.members, a),
      for (final a in _readOnly) (PermissionModule.attendance, a),
      for (final a in _readOnly) (PermissionModule.liturgy, a),
    ],
  };
}
