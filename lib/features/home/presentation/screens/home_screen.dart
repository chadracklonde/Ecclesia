import 'package:flutter/material.dart';

import '../../../admin/presentation/screens/admin_screen.dart';
import '../../../attendance/presentation/screens/attendance_screen.dart';
import '../../../attendance/presentation/screens/members_to_visit_screen.dart';
import '../../../classes_subgroups/presentation/screens/classes_list_screen.dart';
import '../../../classes_subgroups/presentation/screens/subgroups_list_screen.dart';
import '../../../finance/presentation/screens/finance_screen.dart';
import '../../../liturgy/presentation/screens/services_list_screen.dart';
import '../../../members/presentation/screens/members_list_screen.dart';
import '../../../secretariat/presentation/screens/documents_list_screen.dart';
import '../../../secretariat/presentation/screens/inventory_list_screen.dart';
import '../../../../core/widgets/ecclesia_logo.dart';

/// Un point d'entrée de l'accueil : icône, libellé, et l'écran à ouvrir.
/// Centraliser cette liste évite de dupliquer 10 fois la même structure
/// entre la disposition mobile (liste) et la disposition large écran
/// (grille) introduites à l'Étape 10 pour la responsivité.
class _HomeDestination {
  final IconData icon;
  final String label;
  final Widget Function() buildScreen;

  const _HomeDestination(this.icon, this.label, this.buildScreen);
}

class HomeScreen extends StatelessWidget {
  final String churchId;

  const HomeScreen({super.key, required this.churchId});

  List<_HomeDestination> _destinations() => [
        _HomeDestination(Icons.people, 'Membres',
            () => MembersListScreen(churchId: churchId)),
        _HomeDestination(Icons.groups, 'Classes',
            () => ClassesListScreen(churchId: churchId)),
        _HomeDestination(Icons.diversity_3, 'Sous-groupes',
            () => SubgroupsListScreen(churchId: churchId)),
        _HomeDestination(Icons.fact_check_outlined, 'Présences',
            () => AttendanceScreen(churchId: churchId)),
        _HomeDestination(Icons.home_outlined, 'Fidèles à visiter',
            () => MembersToVisitScreen(churchId: churchId)),
        _HomeDestination(Icons.account_balance_wallet_outlined, 'Finances',
            () => FinanceScreen(churchId: churchId)),
        _HomeDestination(Icons.calendar_today_outlined, 'Cultes',
            () => ServicesListScreen(churchId: churchId)),
        _HomeDestination(Icons.description_outlined, 'Documents',
            () => DocumentsListScreen(churchId: churchId)),
        _HomeDestination(Icons.inventory_2_outlined, 'Inventaire',
            () => InventoryListScreen(churchId: churchId)),
        _HomeDestination(Icons.admin_panel_settings_outlined, 'Administration',
            () => AdminScreen(churchId: churchId)),
      ];

  void _open(BuildContext context, _HomeDestination destination) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => destination.buildScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final destinations = _destinations();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            EcclesiaIcon(size: 28),
            SizedBox(width: 10),
            Text('Ecclesia'),
          ],
        ),
      ),
      // Étape 10 : disposition adaptative — liste verticale sur mobile,
      // grille sur tablette/desktop/web pour exploiter la largeur
      // disponible plutôt que de gaspiller l'espace avec une colonne
      // unique étirée.
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;
          if (!isWide) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: destinations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final destination = destinations[index];
                return Card(
                  child: ListTile(
                    leading: Icon(destination.icon),
                    title: Text(destination.label),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _open(context, destination),
                  ),
                );
              },
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
            ),
            itemCount: destinations.length,
            itemBuilder: (context, index) {
              final destination = destinations[index];
              return Card(
                child: InkWell(
                  onTap: () => _open(context, destination),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(destination.icon, size: 32),
                        const SizedBox(height: 12),
                        Text(destination.label, textAlign: TextAlign.center),
                      ],
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
