import 'package:drift/native.dart';
import 'package:ecclesia/core/database/database.dart';
import 'package:ecclesia/features/admin/data/datasources/local_role_datasource.dart';
import 'package:ecclesia/features/admin/data/datasources/local_user_account_datasource.dart';
import 'package:ecclesia/features/admin/data/repositories/role_repository_impl.dart';
import 'package:ecclesia/features/admin/data/repositories/user_account_repository_impl.dart';
import 'package:ecclesia/features/admin/domain/entities/role.dart';
import 'package:ecclesia/features/admin/domain/entities/user_account.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late RoleRepositoryImpl roleRepository;
  late PermissionRepositoryImpl permissionRepository;
  late UserAccountRepositoryImpl userAccountRepository;

  const churchId = 'church-1';

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.into(db.churches).insert(
        ChurchesCompanion.insert(id: churchId, code: 'RTC', name: 'RTC-MALI'));
    roleRepository = RoleRepositoryImpl(LocalRoleDataSource(db));
    permissionRepository =
        PermissionRepositoryImpl(LocalPermissionDataSource(db));
    userAccountRepository =
        UserAccountRepositoryImpl(dataSource: LocalUserAccountDataSource(db));
  });

  tearDown(() async {
    await db.close();
  });

  group('RoleRepositoryImpl / PermissionRepositoryImpl', () {
    test('setPermissions remplace intégralement les permissions d\'un rôle',
        () async {
      await roleRepository.createRole(
          const Role(id: 'role-1', churchId: churchId, name: RoleName.secretaire));

      await permissionRepository.setPermissions('role-1', const [
        Permission(
            id: 'p1',
            roleId: 'role-1',
            module: PermissionModule.members,
            action: PermissionAction.create),
        Permission(
            id: 'p2',
            roleId: 'role-1',
            module: PermissionModule.members,
            action: PermissionAction.read),
      ]);

      // Remplacement : la nouvelle liste ne doit contenir qu'un seul droit.
      await permissionRepository.setPermissions('role-1', const [
        Permission(
            id: 'p3',
            roleId: 'role-1',
            module: PermissionModule.members,
            action: PermissionAction.read),
      ]);

      final result = await permissionRepository.getPermissionsForRole('role-1');
      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (permissions) => expect(permissions.length, 1),
      );
    });
  });

  group('UserAccountRepositoryImpl', () {
    test('createUserAccount puis authenticate avec le bon mot de passe réussit',
        () async {
      await roleRepository.createRole(
          const Role(id: 'role-1', churchId: churchId, name: RoleName.secretaire));

      await userAccountRepository.createUserAccount(
        account: const UserAccount(
          id: 'user-1',
          churchId: churchId,
          username: 'marie.secretaire',
          roleId: 'role-1',
        ),
        plainPassword: 'motdepasse123',
      );

      final result = await userAccountRepository.authenticate(
        username: 'marie.secretaire',
        plainPassword: 'motdepasse123',
      );
      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (account) => expect(account.username, 'marie.secretaire'),
      );
    });

    test('authenticate échoue avec un mauvais mot de passe', () async {
      await roleRepository.createRole(
          const Role(id: 'role-1', churchId: churchId, name: RoleName.secretaire));
      await userAccountRepository.createUserAccount(
        account: const UserAccount(
          id: 'user-1',
          churchId: churchId,
          username: 'marie.secretaire',
          roleId: 'role-1',
        ),
        plainPassword: 'motdepasse123',
      );

      final result = await userAccountRepository.authenticate(
        username: 'marie.secretaire',
        plainPassword: 'mauvais_mot_de_passe',
      );
      expect(result.isSuccess, isFalse);
    });

    test('createUserAccount rejette un nom d\'utilisateur déjà pris', () async {
      await roleRepository.createRole(
          const Role(id: 'role-1', churchId: churchId, name: RoleName.secretaire));
      const account = UserAccount(
        id: 'user-1',
        churchId: churchId,
        username: 'marie.secretaire',
        roleId: 'role-1',
      );
      await userAccountRepository.createUserAccount(
          account: account, plainPassword: 'motdepasse123');

      final second = await userAccountRepository.createUserAccount(
        account: const UserAccount(
          id: 'user-2',
          churchId: churchId,
          username: 'marie.secretaire', // même nom
          roleId: 'role-1',
        ),
        plainPassword: 'autremotdepasse',
      );
      expect(second.isSuccess, isFalse);
    });
  });
}
