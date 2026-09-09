import 'package:supabase_flutter/supabase_flutter.dart';

import 'entity_sync_adapter.dart';

/// Pousse les lignes locales non synchronisées vers Supabase, puis
/// récupère les changements distants plus récents que `since`.
///
/// ⚠️ NON VÉRIFIÉ DANS CE SANDBOX : API de `supabase_flutter` au mieux
/// de ma connaissance du paquet — à confirmer via `flutter pub get` et
/// un vrai projet Supabase en local (`SupabaseConfig` à remplir avant).
class TableSyncService<TRow> {
  final SupabaseClient client;
  final EntitySyncAdapter<TRow> adapter;

  TableSyncService({required this.client, required this.adapter});

  Future<int> push() async {
    final unsynced = await adapter.getUnsyncedLocal();
    for (final row in unsynced) {
      await client.from(adapter.tableName).upsert(adapter.toRemoteJson(row));
      await adapter.markSynced(adapter.idOf(row));
    }
    return unsynced.length;
  }

  Future<int> pull({required DateTime since}) async {
    final response = await client
        .from(adapter.tableName)
        .select()
        .gt('updated_at', since.toIso8601String());

    final rows = response as List;
    for (final raw in rows) {
      final remote = adapter.fromRemoteJson(raw as Map<String, dynamic>);
      await adapter.upsertLocal(remote);
    }
    return rows.length;
  }

  Future<void> syncNow({required DateTime lastSyncTime}) async {
    await push();
    await pull(since: lastSyncTime);
  }
}
