import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';

import '../secret_key_provider.dart';

/// Connexion native (iOS/Android/macOS/Windows) — fichier SQLite local
/// CHIFFRÉ via SQLCipher (décision actée à l'Étape 1, enfin câblée).
///
/// ⚠️ NON VÉRIFIÉ DANS CE SANDBOX : `applyWorkaroundToOpenSqlCipherOnOldAndroidVersions()`
/// et le `PRAGMA key` ci-dessous suivent le pattern documenté officiellement
/// par `drift` pour SQLCipher, au meilleur de ma connaissance — mais je ne
/// peux ni compiler ni exécuter ce code ici. Avant de faire confiance à ce
/// fichier :
///   1. `flutter pub get`, vérifier que `sqlcipher_flutter_libs` et `drift`
///      s'accordent sur la version de SQLite embarquée.
///   2. Tester l'ouverture sur chaque plateforme cible séparément — le
///      comportement natif diffère (Android a besoin du "workaround" pour
///      les anciennes versions, iOS/macOS/Windows non).
///   3. Si une base NON chiffrée existe déjà d'un run précédent de ce
///      projet (avant ce commit), sa migration vers une base chiffrée
///      n'est PAS gérée ici — supprimer l'ancien fichier ou écrire un
///      script de migration séparé.
QueryExecutor connect() {
  return LazyDatabase(() async {
    await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();

    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ecclesia.sqlite'));

    final secretKeyProvider = SecretKeyProvider();
    final key = await secretKeyProvider.getOrCreateKey();

    return NativeDatabase.createInBackground(
      file,
      setup: (rawDb) {
        rawDb.execute("PRAGMA key = \"x'$key'\";");
      },
    );
  });
}
