import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/service.dart';
import '../providers/liturgy_list_providers.dart';
import 'service_detail_screen.dart';
import 'service_form_screen.dart';

class ServicesListScreen extends ConsumerWidget {
  final String churchId;

  const ServicesListScreen({super.key, required this.churchId});

  String _typeLabel(ServiceType type) {
    switch (type) {
      case ServiceType.dominical:
        return 'Culte dominical';
      case ServiceType.special:
        return 'Culte spécial';
      case ServiceType.veillee:
        return 'Veillée';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesListProvider(churchId));

    return Scaffold(
      appBar: AppBar(title: const Text('Cultes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => ServiceFormScreen(churchId: churchId),
            ),
          );
          if (created == true) {
            ref.invalidate(servicesListProvider(churchId));
          }
        },
        child: const Icon(Icons.add),
      ),
      body: servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erreur : $error')),
        data: (services) {
          if (services.isEmpty) {
            return const Center(child: Text('Aucun culte planifié.'));
          }
          return ListView.separated(
            itemCount: services.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final service = services[index];
              return ListTile(
                title: Text(_typeLabel(service.type)),
                subtitle: Text(
                  '${service.date.day}/${service.date.month}/${service.date.year}'
                  '${service.theme != null ? ' — ${service.theme}' : ''}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ServiceDetailScreen(
                      churchId: churchId,
                      service: service,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
