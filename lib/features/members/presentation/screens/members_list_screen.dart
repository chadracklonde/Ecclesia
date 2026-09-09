import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/members_list_provider.dart';
import '../widgets/status_badge.dart';
import 'member_detail_screen.dart';
import 'member_form_screen.dart';

class MembersListScreen extends ConsumerWidget {
  final String churchId;

  const MembersListScreen({super.key, required this.churchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersListProvider(churchId));

    return Scaffold(
      appBar: AppBar(title: const Text('Membres')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => MemberFormScreen(churchId: churchId),
            ),
          );
          if (created == true) {
            ref.invalidate(membersListProvider(churchId));
          }
        },
        child: const Icon(Icons.add),
      ),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erreur : $error')),
        data: (members) {
          if (members.isEmpty) {
            return const Center(
              child: Text('Aucun membre enregistré pour le moment.'),
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
                trailing: StatusBadge(status: member.status),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MemberDetailScreen(memberId: member.id),
                    ),
                  );
                  ref.invalidate(membersListProvider(churchId));
                },
              );
            },
          );
        },
      ),
    );
  }
}
