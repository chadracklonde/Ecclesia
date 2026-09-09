import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/role.dart';
import '../entities/user_account.dart';
import '../repositories/role_repository.dart';
import '../repositories/user_account_repository.dart';

class CreateUserAccount {
  final UserAccountRepository userAccountRepository;
  final RoleRepository roleRepository;
  final Uuid uuid;

  CreateUserAccount({
    required this.userAccountRepository,
    required this.roleRepository,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  Future<Result<UserAccount>> call({
    required String churchId,
    required String username,
    required String plainPassword,
    required String roleId,
    String? memberId,
  }) async {
    if (username.trim().isEmpty) {
      return const Error(
          ValidationFailure('Le nom d\'utilisateur est obligatoire'));
    }
    if (plainPassword.length < 8) {
      return const Error(
          ValidationFailure('Le mot de passe doit contenir au moins 8 caractères'));
    }

    final roleResult = await roleRepository.getRoleById(roleId);
    if (roleResult is Error<Role>) {
      return const Error(ValidationFailure('Rôle introuvable'));
    }

    final account = UserAccount(
      id: uuid.v4(),
      churchId: churchId,
      username: username.trim(),
      memberId: memberId,
      roleId: roleId,
    );

    return userAccountRepository.createUserAccount(
      account: account,
      plainPassword: plainPassword,
    );
  }
}

class AuthenticateUser {
  final UserAccountRepository repository;

  AuthenticateUser(this.repository);

  Future<Result<UserAccount>> call({
    required String username,
    required String plainPassword,
  }) {
    if (username.trim().isEmpty || plainPassword.isEmpty) {
      return Future.value(
          const Error(ValidationFailure('Identifiants incorrects')));
    }
    return repository.authenticate(
      username: username.trim(),
      plainPassword: plainPassword,
    );
  }
}
