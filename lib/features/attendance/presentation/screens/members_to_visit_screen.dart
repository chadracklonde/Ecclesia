import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/attendance_list_providers.dart';

class MembersToVisitScreen extends ConsumerWidget {
  final String churchId;

  const MembersToVisitScreen({super.key, required this.churchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toVisitAsync = ref.watch(membersToVisitProvider(churchId));

    return Scaffold(
      appBar: AppBar(title: const Text('Fidèles à visiter')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Membres sans pointage de présence depuis 30 jours.',
              style: TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            child: toVisitAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Erreur : $error')),
              data: (members) {
                if (members.isEmpty) {
                  return const Center(
                    child: Text('Tous les membres ont été vus récemment.'),
                  );
                }
                return ListView.separated(
                  itemCount: members.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return ListTile(
                      leading: const Icon(Icons.home_outlined),
                      title: Text('${member.firstName} ${member.lastName}'),
                      subtitle: Text(member.matricule),
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
