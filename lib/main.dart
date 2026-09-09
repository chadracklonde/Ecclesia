import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/database/database_provider.dart';
import 'core/database/seed.dart';
import 'core/sync/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/ecclesia_logo.dart';
import 'features/home/presentation/screens/home_screen.dart';

Future<void> main() async {
  // Supabase reste optionnel : l'app doit rester 100% utilisable hors-ligne
  // même sans configuration Supabase (décision actée Étape 1/10).
  if (SupabaseConfig.isConfigured) {
    WidgetsFlutterBinding.ensureInitialized();
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }
  runApp(const ProviderScope(child: EcclesiaApp()));
}

/// Amorce l'église de démonstration avant d'afficher l'écran principal.
/// À REMPLACER par le véritable flux de configuration d'église (Étape 9).
final _demoChurchSeedProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  await ensureDemoChurch(
    db,
    id: 'church-demo',
    code: 'RTC',
    name: 'RTC-MALI (démo)',
  );
});

class EcclesiaApp extends ConsumerWidget {
  const EcclesiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seed = ref.watch(_demoChurchSeedProvider);

    return MaterialApp(
      title: 'Ecclesia',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: seed.when(
        loading: () => const Scaffold(
          body: Center(child: EcclesiaLogoFull(iconSize: 120)),
        ),
        error: (error, _) =>
            Scaffold(body: Center(child: Text('Erreur d\'initialisation : $error'))),
        data: (_) => const HomeScreen(churchId: 'church-demo'),
      ),
    );
  }
}
