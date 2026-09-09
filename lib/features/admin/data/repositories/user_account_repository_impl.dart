import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_account.dart';
import '../../domain/repositories/user_account_repository.dart';
import '../datasources/local_user_account_datasource.dart';
import '../models/admin_model.dart';
import '../password_hasher.dart';

class UserAccountRepositoryImpl implements UserAccountRepository {
  final LocalUserAccountDataSource dataSource;
  final PasswordHasher passwordHasher;

  UserAccountRepositoryImpl({
    required this.dataSource,
    PasswordHasher? passwordHasher,
  }) : passwordHasher = passwordHasher ?? PasswordHasher();

  @override
  Future<Result<UserAccount>> createUserAccount({
    required UserAccount account,
    required String plainPassword,
  }) async {
    try {
      final existing = await dataSource.getByUsername(account.username);
      if (existing != null) {
        return const Error(
            ValidationFailure('Ce nom d\'utilisateur est déjà pris'));
      }

      final salt = passwordHasher.generateSalt();
      final hash = passwordHasher.hash(plainPassword, salt);

      await dataSource.insert(
        account.toCompanion(passwordHash: hash, passwordSalt: salt),
      );
      return Success(account);
    } catch (e) {
      return Error(DatabaseFailure('Échec de la création du compte : $e'));
    }
  }

  @override
  Future<Result<UserAccount>> authenticate({
    required String username,
    required String plainPassword,
  }) async {
    try {
      final row = await dataSource.getByUsername(username);
      if (row == null) {
        return const Error(
            ValidationFailure('Identifiants incorrects')); // message volontairement générique
      }
      if (!row.isActive) {
        return const Error(ValidationFailure('Ce compte est désactivé'));
      }
      final matches = passwordHasher.verify(
        plainPassword,
        row.passwordSalt,
        row.passwordHash,
      );
      if (!matches) {
        return const Error(ValidationFailure('Identifiants incorrects'));
      }
      return Success(row.toDomain());
    } catch (e) {
      return Error(DatabaseFailure('Échec de l\'authentification : $e'));
    }
  }

  @override
  Future<Result<List<UserAccount>>> getUserAccountsForChurch({
    required String churchId,
  }) async {
    try {
      final rows = await dataSource.getForChurch(churchId);
      return Success(rows.map((r) => r.toDomain()).toList());
    } catch (e) {
      return Error(DatabaseFailure('Échec de la lecture des comptes : $e'));
    }
  }
}
