import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/secretariat_list_providers.dart';
import '../providers/secretariat_providers.dart';
import 'inventory_form_screen.dart';

class InventoryListScreen extends ConsumerWidget {
  final String churchId;

  const InventoryListScreen({super.key, required this.churchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(inventoryListProvider(churchId));

    return Scaffold(
      appBar: AppBar(title: const Text('Inventaire')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => InventoryFormScreen(churchId: churchId),
            ),
          );
          if (created == true) {
            ref.invalidate(inventoryListProvider(churchId));
          }
        },
        child: const Icon(Icons.add),
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erreur : $error')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Aucun article enregistré.'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text([
                  if (item.category != null) item.category!,
                  if (item.location != null) item.location!,
                  if (item.condition != null) item.condition!,
                ].join(' · ')),
                trailing: Text('×${item.quantity}'),
                onLongPress: () async {
                  final deleteItem = ref.read(deleteInventoryItemProvider);
                  await deleteItem(item.id);
                  ref.invalidate(inventoryListProvider(churchId));
                },
              );
            },
          );
        },
      ),
    );
  }
}
