import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/community_list_providers.dart';
import 'subgroup_detail_screen.dart';
import 'subgroup_form_screen.dart';

class SubgroupsListScreen extends ConsumerWidget {
  final String churchId;

  const SubgroupsListScreen({super.key, required this.churchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subgroupsAsync = ref.watch(subgroupsListProvider(churchId));

    return Scaffold(
      appBar: AppBar(title: const Text('Sous-groupes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => SubgroupFormScreen(churchId: churchId),
            ),
          );
          if (created == true) {
            ref.invalidate(subgroupsListProvider(churchId));
          }
        },
        child: const Icon(Icons.add),
      ),
      body: subgroupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erreur : $error')),
        data: (subgroups) {
          if (subgroups.isEmpty) {
            return const Center(
              child: Text('Aucun sous-groupe pour le moment.'),
            );
          }
          return ListView.separated(
            itemCount: subgroups.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final subgroup = subgroups[index];
              return ListTile(
                title: Text(subgroup.name),
                subtitle: Text(subgroup.type),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SubgroupDetailScreen(
                        churchId: churchId,
                        subgroup: subgroup,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
