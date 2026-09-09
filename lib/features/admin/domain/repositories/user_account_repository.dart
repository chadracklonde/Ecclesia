import '../../../../core/utils/result.dart';
import '../entities/user_account.dart';

abstract class UserAccountRepository {
  /// Le hachage du mot de passe se fait dans l'implémentation (couche
  /// data) — le usecase appelant fournit le mot de passe en clair
  /// uniquement à cet instant, jamais stocké tel quel.
  Future<Result<UserAccount>> createUserAccount({
    required UserAccount account,
    required String plainPassword,
  });

  Future<Result<UserAccount>> authenticate({
    required String username,
    required String plainPassword,
  });

  Future<Result<List<UserAccount>>> getUserAccountsForChurch({
    required String churchId,
  });
}
