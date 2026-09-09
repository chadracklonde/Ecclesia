/// Contrat générique pour synchroniser une table locale `drift` avec sa
/// table miroir Supabase (Étape 11). Un adaptateur par table — un seul
/// est implémenté pour l'instant (`MemberSyncAdapter`), comme exemple de
/// référence à dupliquer pour les 17 autres tables. Le même mécanisme
/// `is_synced`/`updated_at`, déjà présent sur (presque) toutes les
/// tables depuis l'Étape 1, sert directement de file d'attente de
/// synchronisation implicite — pas besoin d'une table `sync_queue`
/// séparée.
abstract class EntitySyncAdapter<TRow> {
  /// Nom de la table Supabase distante (généralement identique au nom
  /// de la table locale en snake_case).
  String get tableName;

  /// Lignes locales non encore synchronisées (`is_synced = false`).
  Future<List<TRow>> getUnsyncedLocal();

  Future<void> markSynced(String id);

  Map<String, dynamic> toRemoteJson(TRow row);

  TRow fromRemoteJson(Map<String, dynamic> json);

  /// Insère ou met à jour localement (résolution de conflit :
  /// last-write-wins par `updated_at`, décision actée à l'Étape 1 —
  /// SAUF pour les Finances, qui déclenchent une alerte manuelle plutôt
  /// qu'une fusion automatique. `FinanceSyncAdapter` n'est pas encore
  /// implémenté ; cette règle spécifique reste à câbler quand il le sera).
  Future<void> upsertLocal(TRow row);

  DateTime updatedAtOf(TRow row);

  String idOf(TRow row);
}
