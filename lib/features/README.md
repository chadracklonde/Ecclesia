# Ecclesia

Application de gestion complète pour église locale — local-first, multiplateforme (Web, iOS, Android, macOS, Windows).

Projet développé avec Claude comme architecte logiciel senior. La documentation complète du processus (roadmap, décisions, audits) est dans le dossier parent de ce projet — voir la section [Documentation du projet](#documentation-du-projet) plus bas.

---

## ⚠️ Avant de build — lis ceci en premier

Ce projet a été écrit dans un environnement sans SDK Flutter ni accès à pub.dev. **Rien n'a jamais été compilé ni exécuté.** Voici, dans l'ordre, ce qui a le plus de chances de casser ton premier build, et quoi faire.

### 1. Le code généré par `drift` n'existe pas encore — erreur la plus probable

Le projet référence des classes comme `AppDatabase`, `MembersCompanion`, `MemberRow`, etc. qui sont **générées automatiquement**, pas écrites à la main. Sans cette étape, la compilation échoue immédiatement avec des dizaines d'erreurs "undefined class".

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Lance TOUJOURS ces deux commandes avant tout `flutter run`/`flutter test`/`flutter build`.

### 2. Versions des paquets non vérifiées

Toutes les versions dans `pubspec.yaml` sont indicatives — je n'ai jamais pu les vérifier contre pub.dev. Si `flutter pub get` échoue sur un conflit de version, ajuste les contraintes (généralement en assouplissant `^x.y.z` vers une version plus récente).

### 3. Web : fichiers manquants à ajouter manuellement

`lib/core/database/connection/connection_web.dart` utilise `drift/wasm`, qui a besoin de fichiers servis statiquement :
- `sqlite3.wasm` (fourni par le paquet `sqlite3`)
- un worker JS (`drift_worker.js`)

à copier dans le dossier `web/` du projet. Sans ces fichiers, `flutter build web` peut réussir mais l'app plantera à l'ouverture de la base de données. Voir `sqlite3`/`drift` pour la procédure exacte selon leur version.

Autre risque non résolu : `sqlcipher_flutter_libs` dans `pubspec.yaml` ne déclare peut-être pas de support Web — si `flutter build web` échoue à cause de cette dépendance, c'est la cause la plus probable (retire-la temporairement pour confirmer, puis ouvre une issue le temps de trouver une meilleure solution pour le chiffrement sur Web).

### 4. Supabase désactivé par défaut — normal

`core/sync/supabase_config.dart` contient des placeholders (`REMPLACER_PAR_...`). Tant qu'ils ne sont pas remplis, l'app démarre normalement mais toute tentative de synchronisation échoue proprement avec un message clair. Ce n'est PAS un bug — Supabase sera configuré dans une étape ultérieure (voir roadmap).

### 5. Résultat attendu si tout se passe bien

```bash
flutter test
```
**87 tests** doivent passer. Si le nombre diffère, consulte `ecclesia-audit-protocole.md` (dans le dossier parent) — chaque étape y documente son propre delta de tests.

---

## Démarrage rapide

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter run
```

## Structure du projet

Clean Architecture par fonctionnalité (`lib/features/<module>/{domain,data,presentation}`), cœur transverse dans `lib/core/`. 18 tables `drift`, 10 modules métier (Membres, Classes/Sous-groupes, Présences, Finances, Cultes, Secrétariat, Administration, plus l'infrastructure Base de données/Synchro/Widgets partagés).

## TODOs connus, tous documentés en commentaire à l'endroit concerné

- Extension de la synchronisation Supabase aux 17 tables restantes (seul le module Membres a un adaptateur complet pour l'instant — voir `core/sync/entity_sync_adapter.dart` pour le patron à dupliquer)
- Résolution de conflit spécifique aux Finances lors de la synchro (alerte manuelle plutôt que fusion automatique)
- Génération de vraies icônes d'app à partir de `assets/logo/ecclesia_icon.svg` (ex. via `flutter_launcher_icons`)
- Wordmark du logo en police système plutôt qu'Oswald (prévue par la charte)
- Layout maître-détail pour grand écran sur les écrans liste→détail (fait seulement pour l'accueil)

## Documentation du projet

Dans `docs/`, tout le processus de conception :
- `docs/ecclesia-roadmap.md` — feuille de route maîtresse et statut de chaque étape
- `docs/ecclesia-audit-protocole.md` — journal d'audit détaillé, étape par étape, avec chaque décision et sa justification
- `docs/ecclesia-guide-verification-finale.md` — guide de vérification pas à pas (installation, tests, parcours manuel)
- `docs/ecclesia-etape0-modelisation.md` — dictionnaire des entités et règles métier
- `docs/ecclesia-etape1-architecture.md` — architecture technique
- `docs/ecclesia-etape2-design-tokens.md` — charte graphique (couleurs UMC, logo)
- `docs/ecclesia-etape10-multiplateforme.md` — audit et décisions multiplateforme (Web notamment)
