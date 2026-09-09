import '../../../../core/utils/result.dart';

/// Fournit le prochain numéro de séquence pour un matricule, par église
/// et par année. L'implémentation garantit qu'un numéro n'est jamais
/// réutilisé (Étape 0, décision #5), même après suppression d'un membre.
abstract class MatriculeSequenceProvider {
  Future<Result<int>> nextSequence({
    required String churchId,
    required int year,
  });
}
