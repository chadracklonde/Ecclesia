import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Connexion Web via `drift/wasm` (sqlite compilé en WebAssembly,
/// stockage persistant dans le navigateur — OPFS si disponible, sinon
/// IndexedDB en repli automatique côté drift).
///
/// ⚠️ NON VÉRIFIÉ DANS CE SANDBOX — pas d'accès à pub.dev ni au SDK
/// Flutter ici. Cette API est correcte au meilleur de ma connaissance du
/// paquet `drift` au moment de l'écriture, mais l'API exacte de
/// `WasmDatabase.open(...)` peut différer selon la version de `drift`
/// réellement installée. AVANT DE FAIRE CONFIANCE À CE FICHIER :
///   1. `flutter pub get`, vérifier la version de `drift` dans
///      pubspec.lock et son CHANGELOG pour `WasmDatabase.open`.
///   2. Copier les fichiers requis dans `web/` — au minimum
///      `sqlite3.wasm` (fourni par le paquet `sqlite3`, sous-dépendance
///      de `drift`) et un worker JS (`drift_worker.js`, généré par
///      `drift_dev` ou fourni par la doc officielle du paquet). Sans ces
///      fichiers servis par le serveur web, l'ouverture échouera même si
///      ce code compile.
///   3. Tester manuellement dans un navigateur — je ne peux pas le faire
///      ici.
QueryExecutor connect() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'ecclesia',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  });
}
