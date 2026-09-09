import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/role.dart';
import '../../domain/entities/user_account.dart';
import 'admin_providers.dart';

final rolesListProvider =
    FutureProvider.family<List<Role>, String>((ref, churchId) async {
  final repository = ref.watch(roleRepositoryProvider);
  final result = await repository.getRolesForChurch(churchId: churchId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (roles) => roles,
  );
});

final userAccountsListProvider =
    FutureProvider.family<List<UserAccount>, String>((ref, churchId) async {
  final repository = ref.watch(userAccountRepositoryProvider);
  final result = await repository.getUserAccountsForChurch(churchId: churchId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (accounts) => accounts,
  );
});

final backupsListProvider = FutureProvider<List<String>>((ref) async {
  final listBackups = ref.watch(listBackupsUseCaseProvider);
  final result = await listBackups();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (backups) => backups,
  );
});
