/// Erreurs typées du domaine — utilisées avec `Result<T>` plutôt que des
/// exceptions non typées (Étape 1, section 2bis : essentiel pour le module
/// Finances où une erreur silencieuse est inacceptable).
sealed class Failure {
  final String message;
  const Failure(this.message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}
