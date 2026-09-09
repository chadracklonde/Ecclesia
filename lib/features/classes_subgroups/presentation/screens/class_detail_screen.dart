import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../members/domain/entities/member.dart';
import '../../../members/presentation/providers/members_list_provider.dart';
import '../../domain/entities/church_class.dart';
import '../providers/community_list_providers.dart';
import '../providers/community_providers.dart';

class ClassDetailScreen extends ConsumerWidget {
  final String churchId;
  final ChurchClass churchClass;

  const ClassDetailScreen({
    super.key,
    required this.churchId,
    required this.churchClass,
  });

  Future<void> _openAddMemberDialog(BuildContext context, WidgetRef ref) async {
    final allMembersAsync = await ref.read(membersListProvider(churchId).future);
    final currentMembersAsync =
        await ref.read(classMembersProvider(churchClass.id).future);
    final currentIds = currentMembersAsync.map((m) => m.id).toSet();
    final candidates =
        allMembersAsync.where((m) => !currentIds.contains(m.id)).toList();

    if (!context.mounted) return;

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tous les membres sont déjà dans cette classe.')),
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

    if (selected == null) return;

    final assignMemberToClass = ref.read(assignMemberToClassProvider);
    final result = await assignMemberToClass(
      memberId: selected.id,
      classId: churchClass.id,
    );

    if (!context.mounted) return;

    result.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => ref.invalidate(classMembersProvider(churchClass.id)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(classMembersProvider(churchClass.id));

    return Scaffold(
      appBar: AppBar(title: Text(churchClass.name)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddMemberDialog(context, ref),
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (churchClass.description != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(churchClass.description!),
            ),
          Expanded(
            child: membersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Erreur : $error')),
              data: (members) {
                if (members.isEmpty) {
                  return const Center(
                    child: Text('Aucun membre rattaché à cette classe.'),
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
                        tooltip: 'Retirer de la classe',
                        onPressed: () async {
                          final repository = ref.read(churchClassRepositoryProvider);
                          await repository.removeMemberFromClass(
                            memberId: member.id,
                            classId: churchClass.id,
                          );
                          ref.invalidate(classMembersProvider(churchClass.id));
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
