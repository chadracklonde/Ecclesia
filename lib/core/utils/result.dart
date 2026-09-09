import '../errors/failures.dart';

/// Équivalent léger à `Either<Failure, T>`, sans dépendance externe —
/// choix fait pour ne pas ajouter un paquet dont je ne peux pas vérifier
/// la version dans ce sandbox (pas d'accès à pub.dev).
sealed class Result<T> {
  const Result();

  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T value) onSuccess,
  ) {
    final self = this;
    if (self is Success<T>) return onSuccess(self.value);
    if (self is Error<T>) return onFailure(self.failure);
    throw StateError('Unknown Result subtype: $runtimeType');
  }

  bool get isSuccess => this is Success<T>;
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
