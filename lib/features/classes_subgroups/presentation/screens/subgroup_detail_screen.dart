import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../members/domain/entities/member.dart';
import '../../../members/presentation/providers/members_list_provider.dart';
import '../../domain/entities/subgroup.dart';
import '../providers/community_list_providers.dart';
import '../providers/community_providers.dart';

class SubgroupDetailScreen extends ConsumerWidget {
  final String churchId;
  final Subgroup subgroup;

  const SubgroupDetailScreen({
    super.key,
    required this.churchId,
    required this.subgroup,
  });

  Future<void> _openAddMemberDialog(BuildContext context, WidgetRef ref) async {
    final allMembers = await ref.read(membersListProvider(churchId).future);
    final currentMembers =
        await ref.read(subgroupMembersProvider(subgroup.id).future);
    final currentIds = currentMembers.map((m) => m.id).toSet();
    final candidates =
        allMembers.where((m) => !currentIds.contains(m.id)).toList();

    if (!context.mounted) return;

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tous les membres sont déjà dans ce sous-groupe.')),
      );
      return;
    }

    final selected = await showDialog<Member>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Ajouter un membre'),
        children: candidates
            .map((member) => SimpleDialogOption(
                  onPressed: () => Navigator.of(dialogContext).pop(member),
                  child: Text('${member.firstName} ${member.lastName}'),
                ))
            .toList(),
      ),
    );

    if (selected == null || !context.mounted) return;

    final role = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Rôle dans le sous-groupe'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(dialogContext).pop('membre'),
            child: const Text('Membre'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(dialogContext).pop('responsable'),
            child: const Text('Responsable'),
          ),
        ],
      ),
    );

    if (role == null || !context.mounted) return;

    final assignMemberToSubgroup = ref.read(assignMemberToSubgroupProvider);
    final result = await assignMemberToSubgroup(
      memberId: selected.id,
      subgroupId: subgroup.id,
      roleInGroup: role,
    );

    if (!context.mounted) return;

    result.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => ref.invalidate(subgroupMembersProvider(subgroup.id)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(subgroupMembersProvider(subgroup.id));

    return Scaffold(
      appBar: AppBar(title: Text(subgroup.name)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddMemberDialog(context, ref),
        child: const Icon(Icons.person_add),
      ),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erreur : $error')),
        data: (members) {
          if (members.isEmpty) {
            return const Center(
              child: Text('Aucun membre rattaché à ce sous-groupe.'),
            );
          }
          return ListView.separated(
            itemCount: members.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final member = members[index];
              return ListTile(
                title: Text('${member.firstName} ${member.lastName}'),
                subtitle: Text(member.matricule),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: 'Retirer du sous-groupe',
                  onPressed: () async {
                    final repository = ref.read(subgroupRepositoryProvider);
                    await repository.removeMemberFromSubgroup(
                      memberId: member.id,
                      subgroupId: subgroup.id,
                    );
                    ref.invalidate(subgroupMembersProvider(subgroup.id));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
