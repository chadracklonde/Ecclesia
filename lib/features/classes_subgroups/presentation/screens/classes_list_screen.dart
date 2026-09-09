import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/community_list_providers.dart';
import 'class_detail_screen.dart';
import 'class_form_screen.dart';

class ClassesListScreen extends ConsumerWidget {
  final String churchId;

  const ClassesListScreen({super.key, required this.churchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(classesListProvider(churchId));

    return Scaffold(
      appBar: AppBar(title: const Text('Classes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => ClassFormScreen(churchId: churchId),
            ),
          );
          if (created == true) {
            ref.invalidate(classesListProvider(churchId));
          }
        },
        child: const Icon(Icons.add),
      ),
      body: classesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erreur : $error')),
        data: (classes) {
          if (classes.isEmpty) {
            return const Center(child: Text('Aucune classe pour le moment.'));
          }
          return ListView.separated(
            itemCount: classes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final churchClass = classes[index];
              return ListTile(
                title: Text(churchClass.name),
                subtitle: churchClass.description != null
                    ? Text(churchClass.description!)
                    : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ClassDetailScreen(
                        churchId: churchId,
                        churchClass: churchClass,
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
