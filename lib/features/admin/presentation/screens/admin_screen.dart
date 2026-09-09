import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/sync/supabase_config.dart';
import '../../../../core/sync/table_sync_service.dart';
import '../../../members/data/sync/member_sync_adapter.dart';
import '../../domain/entities/role.dart';
import '../providers/admin_list_providers.dart';
import '../providers/admin_providers.dart';
import 'user_account_form_screen.dart';

class AdminScreen extends ConsumerWidget {
  final String churchId;

  const AdminScreen({super.key, required this.churchId});

  String _roleLabel(RoleName name) {
    switch (name) {
      case RoleName.superAdmin:
        return 'Super Admin';
      case RoleName.pasteur:
        return 'Pasteur';
      case RoleName.tresorier:
        return 'Trésorier';
      case RoleName.secretaire:
        return 'Secrétaire';
      case RoleName.responsableClasse:
        return 'Responsable de classe';
      case RoleName.membreLecture:
        return 'Membre (lecture)';
    }
  }

  // Simplification assumée : dernière synchro gardée en mémoire pour la
  // session, pas persistée entre redémarrages — à faire évoluer vers un
  // stockage local (ex. shared_preferences) si besoin réel.
  static DateTime _lastMemberSync = DateTime(2000);

  Future<void> _syncMembers(BuildContext context, WidgetRef ref) async {
    if (!SupabaseConfig.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Supabase non configuré (core/sync/supabase_config.dart) — synchronisation indisponible.'),
      ));
      return;
    }

    if (!kIsWeb) {
      final connectivity = await Connectivity().checkConnectivity();
      final offline = connectivity.contains(ConnectivityResult.none) ||
          connectivity.isEmpty;
      if (offline) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pas de connexion — synchro reportée.')),
        );
        return;
      }
    }

    final db = ref.read(appDatabaseProvider);
    final service = TableSyncService(
      client: Supabase.instance.client,
      adapter: MemberSyncAdapter(db),
    );

    try {
      await service.syncNow(lastSyncTime: _lastMemberSync);
      _lastMemberSync = DateTime.now();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Membres synchronisés avec Supabase.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Échec de la synchro : $e')));
    }
  }

  Future<void> _seedRoles(BuildContext context, WidgetRef ref) async {
    final seed = ref.read(seedDefaultRolesProvider);
    final result = await seed(churchId: churchId);
    if (!context.mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        ref.invalidate(rolesListProvider(churchId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rôles initialisés.')),
        );
      },
    );
  }

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    final exportBackup = ref.read(exportBackupProvider);
    final result = await exportBackup();
    if (!context.mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message))),
      (path) {
        ref.invalidate(backupsListProvider);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sauvegarde créée : $path')));
      },
    );
  }

  Future<void> _restoreBackup(
    BuildContext context,
    WidgetRef ref,
    String backupPath,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restaurer cette sauvegarde ?'),
        content: const Text(
          'Toutes les données actuelles seront remplacées par celles de la sauvegarde. '
          'Un redémarrage de l\'application sera nécessaire ensuite.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Restaurer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final importBackup = ref.read(importBackupProvider);
    final result = await importBackup(backupPath);
    if (!context.mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Sauvegarde restaurée'),
          content: const Text(
            'Ferme complètement l\'application puis relance-la pour que la restauration prenne effet.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Compris'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(rolesListProvider(churchId));
    final usersAsync = ref.watch(userAccountsListProvider(churchId));
    final backupsAsync = ref.watch(backupsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Administration')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Rôles', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          rolesAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (error, _) => Text('Erreur : $error'),
            data: (roles) {
              if (roles.isEmpty) {
                return OutlinedButton(
                  onPressed: () => _seedRoles(context, ref),
                  child: const Text('Initialiser les rôles par défaut'),
                );
              }
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: roles
                    .map((r) => Chip(label: Text(_roleLabel(r.name))))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Synchronisation', style: Theme.of(context).textTheme.titleMedium),
              TextButton(
                onPressed: () => _syncMembers(context, ref),
                child: const Text('Synchroniser maintenant'),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Étape 11 (en construction) : seul le module Membres est câblé '
              'pour l\'instant, comme exemple de référence. Les autres modules '
              'suivent le même patron (voir core/sync/entity_sync_adapter.dart).',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Comptes utilisateurs', style: Theme.of(context).textTheme.titleMedium),
              TextButton(
                onPressed: () async {
                  final created = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => UserAccountFormScreen(churchId: churchId),
                    ),
                  );
                  if (created == true) {
                    ref.invalidate(userAccountsListProvider(churchId));
                  }
                },
                child: const Text('Nouveau'),
              ),
            ],
          ),
          usersAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (error, _) => Text('Erreur : $error'),
            data: (users) {
              if (users.isEmpty) {
                return const Text('Aucun compte pour le moment.');
              }
              return Column(
                children: users
                    .map((u) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(u.username),
                          trailing: Text(u.isActive ? 'Actif' : 'Désactivé'),
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sauvegardes locales', style: Theme.of(context).textTheme.titleMedium),
              if (!kIsWeb)
                TextButton(
                  onPressed: () => _exportBackup(context, ref),
                  child: const Text('Sauvegarder maintenant'),
                ),
            ],
          ),
          if (kIsWeb)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'La sauvegarde locale n\'est pas encore disponible sur Web '
                '(limite actée à l\'Étape 10) — disponible sur mobile et desktop.',
              ),
            )
          else
            backupsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, _) => Text('Erreur : $error'),
              data: (backups) {
                if (backups.isEmpty) {
                  return const Text('Aucune sauvegarde pour le moment.');
                }
                return Column(
                  children: backups
                      .map((path) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.save_outlined),
                            title: Text(path.split('/').last),
                            trailing: TextButton(
                              onPressed: () => _restoreBackup(context, ref, path),
                              child: const Text('Restaurer'),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}
