# Ecclesia — Étape 10 : Rapport d'audit multiplateforme

## ⚠️ Problème le plus sérieux trouvé : `dart:io` casse la compilation Web

Le code écrit jusqu'ici (`database.dart`, `seed.dart`, `local_backup_datasource.dart`)
utilise directement `dart:io` (`File`, `Directory`) pour :
- ouvrir la base SQLite (`NativeDatabase` + fichier local),
- amorcer l'église de démonstration,
- exporter/importer les sauvegardes.

**`dart:io` n'existe pas sur Flutter Web.** Ce n'est pas un problème de
compatibilité mineur — un `import 'dart:io'` dans un fichier utilisé par
l'app fait **échouer la compilation web entièrement**, pas juste une
fonctionnalité qui se dégraderait proprement.

Ce n'était pas anticipé aux Étapes 1 à 9 : tout le code a été écrit et
testé (conceptuellement) comme si `NativeDatabase` + fichier local
fonctionnait partout. Ce n'est vrai que sur iOS/Android/macOS/Windows —
pas sur Web.

## Autres risques identifiés par plateforme

| Sujet | iOS/Android | macOS/Windows | Web |
|---|---|---|---|
| `drift` + `NativeDatabase` | ✅ OK | ✅ OK | ❌ Nécessite `drift/wasm` (sql.js + IndexedDB), configuration différente |
| `sqlcipher_flutter_libs` | ✅ OK (natif) | ⚠️ à valider par plateforme | ❌ Pas de chiffrement natif équivalent — sécurité reposerait sur le sandboxing du navigateur uniquement |
| `path_provider` (dossier documents) | ✅ OK | ✅ OK | ❌ Notion de "dossier documents" absente sur Web |
| Sauvegarde export/import (copie de fichier) | ✅ OK | ✅ OK | ❌ Pas de système de fichiers accessible de la même façon |
| Scan QR caméra (déjà non câblé, Étape 5) | ✅ Plausible | ⚠️ Pas de caméra sur beaucoup de postes | ⚠️ Nécessite `getUserMedia`, package web-compatible |
| Formulaires, navigation, Riverpod, Material | ✅ OK | ✅ OK | ✅ OK |

## Décision à trancher : stratégie Web

Deux options raisonnables, avec des implications très différentes :

**Option A — Web reporté, cohérent avec le pattern déjà décidé pour ÉMU Compagnon**
(Étape 12) : le Web se connecte directement à Supabase (pas de SQLite
local), une fois l'Étape 11 (sync) commencée. Ecclesia resterait
mobile+desktop uniquement jusque-là. C'est cohérent avec l'esprit
"local-first d'abord, cloud ensuite" du brief initial, mais retarde la
disponibilité Web.

**Option B — Web dès maintenant via `drift/wasm`** : ajouter une couche
d'abstraction (imports conditionnels `dart:io` vs stubs web) pour que
la même base de code tourne offline sur Web aussi. Plus fidèle au brief
initial ("Plateformes cibles : Web, iOS, Android, macOS, Windows" sans
distinction), mais un chantier technique non trivial que je ne peux pas
vérifier dans ce sandbox (pas d'accès à pub.dev, donc pas de garantie
sur l'API exacte de `drift/wasm`).

## Décision retenue (09/09/2026)

**Option B — Web hors-ligne dès maintenant**, avec synchronisation quand
la connexion revient (comme les autres plateformes, cf. Étape 11).
Raisonnement de l'utilisateur : "Web sera offline et online pour la
synchronisation et l'utilisation sur plusieurs plateformes" — cohérent
avec la contrainte de connectivité intermittente à Kindu qui a motivé
le choix local-first dès l'Étape 1.

## Implémentation réalisée

- `core/database/connection/` : abstraction par import conditionnel
  (`connection_io.dart` / `connection_web.dart` / `connection_stub.dart`),
  sélectionnée à la compilation via `dart.library.io` / `dart.library.html`
  — pattern standard du langage Dart, pas une API tierce.
  `database.dart` ne contient plus `dart:io` du tout.
- `features/admin/data/datasources/local_backup_datasource_{io,web,stub}.dart` :
  même pattern. Sur Web, la sauvegarde/restauration dégrade proprement
  (message explicite dans `AdminScreen`, pas une tentative silencieuse
  qui échouerait).
- `connection_web.dart` implémente l'ouverture via `drift/wasm`
  (`WasmDatabase.open`) **au meilleur de ma connaissance du paquet**,
  mais **non vérifié dans ce sandbox**. Avant de faire confiance à ce
  fichier :
  1. `flutter pub get`, vérifier la version de `drift` installée et son
     CHANGELOG pour l'API exacte de `WasmDatabase.open`.
  2. Ajouter dans `web/` : `sqlite3.wasm` (fourni par le paquet
     `sqlite3`) et un fichier worker JS (`drift_worker.js`) — sans ces
     fichiers servis par le serveur, l'ouverture échoue même si le code
     Dart compile.
  3. Tester manuellement dans un navigateur.

## Ce qui reste non résolu pour le Web (limites assumées, pas cachées)

- **Chiffrement (sqlcipher)** : ne s'applique pas de la même façon sur
  Web. Décision séparée à prendre quand sqlcipher sera réellement câblé
  (actuellement encore un TODO depuis l'Étape 1).
- **Scan QR caméra** (déjà non câblé depuis l'Étape 5) : nécessiterait
  `getUserMedia` côté Web, différent de l'implémentation mobile.
- **`sqlcipher_flutter_libs` dans `pubspec.yaml`** : cette dépendance ne
  déclare probablement pas de support Web — à vérifier si sa seule
  présence dans `pubspec.yaml` (même non importée dans le code Web)
  bloque `flutter build web`. Non vérifiable dans ce sandbox.

## Amélioration responsive (indépendante de la décision Web)

`HomeScreen` bascule entre liste verticale (mobile) et grille
(tablette/desktop/web, ≥700px de large), testé. Les écrans de détail
(liste→détail) restent en navigation plein écran pour l'instant ; un
vrai layout maître-détail pour grand écran reste la suite logique.
