import 'package:ecclesia/core/utils/result.dart';
import 'package:ecclesia/features/admin/domain/entities/role.dart';
import 'package:ecclesia/features/admin/domain/repositories/role_repository.dart';
import 'package:ecclesia/features/admin/domain/usecases/has_permission.dart';
import 'package:ecclesia/features/admin/domain/usecases/seed_default_roles_and_permissions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRoleRepository extends Mock implements RoleRepository {}

class MockPermissionRepository extends Mock implements PermissionRepository {}

void main() {
  group('SeedDefaultRolesAndPermissions', () {
    late MockRoleRepository roleRepository;
    late MockPermissionRepository permissionRepository;
    late SeedDefaultRolesAndPermissions seed;

    setUpAll(() {
      registerFallbackValue(const Role(
          id: 'fallback', churchId: 'church-1', name: RoleName.membreLecture));
      registerFallbackValue(<Permission>[]);
    });

    setUp(() {
      roleRepository = MockRoleRepository();
      permissionRepository = MockPermissionRepository();
      seed = SeedDefaultRolesAndPermissions(
        roleRepository: roleRepository,
        permissionRepository: permissionRepository,
      );

      when(() => roleRepository.createRole(any())).thenAnswer(
          (invocation) async => Success(invocation.positionalArguments.first as Role));
      when(() => permissionRepository.setPermissions(any(), any()))
          .thenAnswer((_) async => const Success(null));
    });

    test('crée les 6 rôles de la matrice de l\'Étape 0', () async {
      final result = await seed(churchId: 'church-1');

      expect(result.isSuccess, isTrue);
      verify(() => roleRepository.createRole(any())).called(6);
    });

    test('le Super Admin reçoit un accès CRUD sur tous les modules',
        () async {
      List<Permission>? superAdminPermissions;
      when(() => roleRepository.createRole(any())).thenAnswer((invocation) async {
        final role = invocation.positionalArguments.first as Role;
        return Success(role);
      });
      when(() => permissionRepository.setPermissions(any(), any()))
          .thenAnswer((invocation) async {
        final roleArg = invocation.positionalArguments[0];
        final permissions =
            invocation.positionalArguments[1] as List<Permission>;
        // On identifie l'appel du Super Admin par son nombre de droits
        // (le seul rôle avec CRUD sur les 7 modules = 28 droits).
        if (permissions.length == PermissionModule.values.length * 4) {
          superAdminPermissions = permissions;
        }
        return const Success(null);
      });

      await seed(churchId: 'church-1');

      expect(superAdminPermissions, isNotNull);
      expect(superAdminPermissions!.length, PermissionModule.values.length * 4);
    });
  });

  group('HasPermission', () {
    late MockPermissionRepository permissionRepository;
    late HasPermission hasPermission;

    setUp(() {
      permissionRepository = MockPermissionRepository();
      hasPermission = HasPermission(permissionRepository);
    });

    test('retourne true si la permission existe pour le rôle', () async {
      when(() => permissionRepository.getPermissionsForRole('role-1'))
          .thenAnswer((_) async => const Success([
                Permission(
                    id: 'p1',
                    roleId: 'role-1',
                    module: PermissionModule.finance,
                    action: PermissionAction.read),
              ]));

      final result = await hasPermission(
        roleId: 'role-1',
        module: PermissionModule.finance,
        action: PermissionAction.read,
      );

      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (allowed) => expect(allowed, isTrue),
      );
    });

    test('retourne false si la permission n\'existe pas pour le rôle',
        () async {
      when(() => permissionRepository.getPermissionsForRole('role-1'))
          .thenAnswer((_) async => const Success([]));

      final result = await hasPermission(
        roleId: 'role-1',
        module: PermissionModule.finance,
        action: PermissionAction.delete,
      );

      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (allowed) => expect(allowed, isFalse),
      );
    });
  });
}
