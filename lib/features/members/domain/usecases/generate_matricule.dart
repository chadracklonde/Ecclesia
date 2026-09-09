/// Génère un matricule au format validé (Étape 0, décision #5) :
/// [CODE-ÉGLISE]-[ANNÉE]-[SÉQUENCE], ex. `RTC-2026-0042`.
///
/// La séquence doit provenir d'un compteur dédié par église/année
/// (jamais d'un `COUNT(*)` sur la table membres), pour garantir
/// qu'un matricule n'est jamais réutilisé même après suppression
/// d'une fiche.
class GenerateMatricule {
  String call({
    required String churchCode,
    required int year,
    required int sequence,
  }) {
    if (churchCode.trim().isEmpty) {
      throw ArgumentError('churchCode must not be empty');
    }
    if (sequence < 1) {
      throw ArgumentError('sequence must be >= 1');
    }
    final paddedSequence = sequence.toString().padLeft(4, '0');
    return '${churchCode.trim().toUpperCase()}-$year-$paddedSequence';
  }
}
