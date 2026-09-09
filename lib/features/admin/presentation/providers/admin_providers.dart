import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/datasources/local_backup_datasource.dart';
import '../../data/datasources/local_role_datasource.dart';
import '../../data/datasources/local_user_account_datasource.dart';
import '../../data/repositories/backup_repository_impl.dart';
import '../../data/repositories/role_repository_impl.dart';
import '../../data/repositories/user_account_repository_impl.dart';
import '../../domain/repositories/backup_repository.dart';
import '../../domain/repositories/role_repository.dart';
import '../../domain/repositories/user_account_repository.dart';
import '../../domain/usecases/backup_usecases.dart';
import '../../domain/usecases/has_permission.dart';
import '../../domain/usecases/seed_default_roles_and_permissions.dart';
import '../../domain/usecases/user_account_usecases.dart';

final roleRepositoryProvider = Provider<RoleRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return RoleRepositoryImpl(LocalRoleDataSource(db));
});

final permissionRepositoryProvider = Provider<PermissionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PermissionRepositoryImpl(LocalPermissionDataSource(db));
});

final userAccountRepositoryProvider = Provider<UserAccountRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return UserAccountRepositoryImpl(dataSource: LocalUserAccountDataSource(db));
});

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BackupRepositoryImpl(LocalBackupDataSource(db: db));
});

final seedDefaultRolesProvider = Provider<SeedDefaultRolesAndPermissions>((ref) {
  return SeedDefaultRolesAndPermissions(
    roleRepository: ref.watch(roleRepositoryProvider),
    permissionRepository: ref.watch(permissionRepositoryProvider),
  );
});

final createUserAccountProvider = Provider<CreateUserAccount>((ref) {
  return CreateUserAccount(
    userAccountRepository: ref.watch(userAccountRepositoryProvider),
    roleRepository: ref.watch(roleRepositoryProvider),
  );
});

final authenticateUserProvider = Provider<AuthenticateUser>((ref) {
  return AuthenticateUser(ref.watch(userAccountRepositoryProvider));
});

final hasPermissionProvider = Provider<HasPermission>((ref) {
  return HasPermission(ref.watch(permissionRepositoryProvider));
});

final exportBackupProvider = Provider<ExportBackup>((ref) {
  return ExportBackup(ref.watch(backupRepositoryProvider));
});

final importBackupProvider = Provider<ImportBackup>((ref) {
  return ImportBackup(ref.watch(backupRepositoryProvider));
});

final listBackupsUseCaseProvider = Provider<ListBackups>((ref) {
  return ListBackups(ref.watch(backupRepositoryProvider));
});
