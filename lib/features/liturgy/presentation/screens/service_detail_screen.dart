import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../members/domain/entities/member.dart';
import '../../../members/presentation/providers/members_list_provider.dart';
import '../../domain/entities/preacher_assignment.dart';
import '../../domain/entities/service.dart';
import '../providers/liturgy_list_providers.dart';
import '../providers/liturgy_providers.dart';

class ServiceDetailScreen extends ConsumerWidget {
  final String churchId;
  final Service service;

  const ServiceDetailScreen({
    super.key,
    required this.churchId,
    required this.service,
  });

  Future<void> _openAssignDialog(BuildContext context, WidgetRef ref) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Affecter un prédicateur'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(dialogContext).pop('member'),
            child: const Text('Choisir un membre'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(dialogContext).pop('external'),
            child: const Text('Prédicateur externe (invité)'),
          ),
        ],
      ),
    );

    if (choice == null || !context.mounted) return;

    String? memberId;
    String? externalName;
    String? externalContact;

    if (choice == 'member') {
      final members = await ref.read(membersListProvider(churchId).future);
      if (!context.mounted) return;
      final selected = await showDialog<Member>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          title: const Text('Choisir un membre'),
          children: members
              .map((m) => SimpleDialogOption(
                    onPressed: () => Navigator.of(dialogContext).pop(m),
                    child: Text('${m.firstName} ${m.lastName}'),
                  ))
              .toList(),
        ),
      );
      if (selected == null) return;
      memberId = selected.id;
    } else {
      if (!context.mounted) return;
      final nameController = TextEditingController();
      final contactController = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Prédicateur externe'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: contactController,
                decoration: const InputDecoration(labelText: 'Contact (optionnel)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Ajouter'),
            ),
          ],
        ),
      );
      if (confirmed != true || nameController.text.trim().isEmpty) return;
      externalName = nameController.text.trim();
      externalContact =
          contactController.text.trim().isEmpty ? null : contactController.text.trim();
    }

    if (!context.mounted) return;

    final assignPreacher = ref.read(assignPreacherProvider);
    final result = await assignPreacher(
      serviceId: service.id,
      memberId: memberId,
      externalName: externalName,
      externalContact: externalContact,
    );

    if (!context.mounted) return;

    result.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => ref.invalidate(preachersForServiceProvider(service.id)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preachersAsync = ref.watch(preachersForServiceProvider(service.id));
    final membersAsync = ref.watch(membersListProvider(churchId));

    return Scaffold(
      appBar: AppBar(
        title: Text('${service.date.day}/${service.date.month}/${service.date.year}'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAssignDialog(context, ref),
        child: const Icon(Icons.person_add_alt),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (service.theme != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(service.theme!, style: Theme.of(context).textTheme.titleMedium),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Prédicateurs', style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: preachersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Erreur : $error')),
              data: (assignments) {
                if (assignments.isEmpty) {
                  return const Center(child: Text('Aucun prédicateur affecté.'));
                }
                final membersById = {
                  for (final m in membersAsync.valueOrNull ?? <Member>[]) m.id: m,
                };
                return ListView.separated(
                  itemCount: assignments.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final PreacherAssignment a = assignments[index];
                    final label = a.isExternal
                        ? (a.externalName ?? '')
                        : () {
                            final member = membersById[a.memberId];
                            return member != null
                                ? '${member.firstName} ${member.lastName}'
                                : a.memberId!;
                          }();
                    return ListTile(
                      leading: Icon(a.isExternal ? Icons.person_outline : Icons.person),
                      title: Text(label),
                      subtitle: Text(a.role == PreacherRole.principal ? 'Principal' : 'Invité'),
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
