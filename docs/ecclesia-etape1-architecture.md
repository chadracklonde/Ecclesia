# Ecclesia — Étape 1 : Architecture technique

## 1. Framework — Flutter (confirmé)

**Justification** :
- Un seul codebase pour Web, iOS, Android, macOS, Windows.
- `drift` (au-dessus de SQLite) offre un ORM type-safe avec migrations versionnées, reactive queries, et fonctionne sur toutes les cibles y compris Web (via `drift/wasm`).
- SDK Dart officiel pour Supabase (`supabase_flutter`), donc la migration vers la synchro cloud (Étape 11) ne demande pas de changement de stack.
- Cohérent avec ÉMU Compagnon et Watoto News — réutilisation de composants, de conventions et de courbe d'apprentissage déjà acquise.

---

## 2. Architecture logicielle — Clean Architecture

Trois couches strictement séparées, par module métier (feature-first, pas layer-first au niveau racine) :

```
lib/
├── core/                         # Transverse à tous les modules
│   ├── database/                 # Définition drift, migrations
│   ├── theme/                    # Design system (Étape 2)
│   ├── router/                   # Navigation (go_router)
│   ├── errors/                   # Failures, exceptions typées
│   └── utils/
│
├── features/
│   ├── members/
│   │   ├── data/
│   │   │   ├── datasources/      # local_member_datasource.dart (drift)
│   │   │   ├── models/           # MemberModel (mapping DB <-> domain)
│   │   │   └── repositories/     # MemberRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/         # Member (pure Dart, sans dépendance DB)
│   │   │   ├── repositories/     # MemberRepository (interface abstraite)
│   │   │   └── usecases/         # CreateMember, ChangeMemberStatus, GenerateMatricule…
│   │   └── presentation/
│   │       ├── providers/        # Riverpod (state management)
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── classes_subgroups/
│   ├── attendance/
│   ├── finance/
│   ├── services_liturgy/
│   ├── secretariat/
│   ├── inventory/
│   └── admin_auth/
│
└── main.dart
```

**Règle stricte** : la couche `domain` ne dépend jamais de `data` ni de `presentation`. La couche `presentation` ne connaît que les `usecases`, jamais `drift` directement. C'est ce qui permettra de brancher Supabase à l'Étape 11 sans toucher à l'UI.

---

## 2bis. Exemple concret — flux du module Membre

```
UI (bouton "Changer statut")
   → Provider Riverpod appelle usecase ChangeMemberStatus(memberId, newStatus)
      → usecase appelle MemberRepository.updateStatus(...)
         → MemberRepositoryImpl écrit dans drift (table members)
                                + insère une ligne dans status_history
         → retourne Either<Failure, Member> au usecase
      → Provider met à jour l'état, UI se rafraîchit automatiquement
```

Gestion d'erreur typée avec `Either<Failure, T>` (package `dartz` ou équivalent maison léger) plutôt que des exceptions non typées — essentiel pour le module Finances où une erreur silencieuse est inacceptable.

---

## 3. State management — Riverpod

**Choix** : Riverpod (over Bloc) pour :
- Moins de boilerplate que Bloc pour un projet de cette taille.
- `AsyncNotifier`/`StreamProvider` s'intègrent nativement avec les requêtes réactives de `drift` (un changement en base met à jour l'UI automatiquement, utile pour Présences en temps réel pendant un culte).
- Testabilité (providers facilement mockables).

---

## 4. Base de données locale — SQLite via `drift`

- Un fichier `.sqlite` par installation, **chiffré au repos via `sqlcipher` dès le squelette du projet** (décision actée — pas différée, vu la sensibilité des données financières et personnelles).
- **Migrations versionnées** : chaque évolution de schéma = une migration numérotée, testée avec des données existantes avant chaque release (pas de perte de données lors des mises à jour de l'app).
- Schéma initial généré directement depuis le dictionnaire d'entités validé à l'Étape 0.

---

## 5. Stratégie de synchronisation Supabase (préparation, activation Étape 11)

- Chaque table locale porte déjà `church_id`, `id` (UUID, pas auto-increment, pour éviter les collisions lors de la fusion avec le cloud), `updated_at`, `is_synced` (bool), `is_deleted` (soft delete).
- Stratégie de résolution de conflits : **last-write-wins basé sur `updated_at`**, sauf pour les Finances où un conflit déclenchera une alerte manuelle plutôt qu'une résolution automatique (l'argent ne doit jamais être fusionné silencieusement).
- File d'attente offline (`sync_queue` table) : chaque écriture locale non synchronisée y est journalisée, rejouée dès que la connexion revient.

---

## 6. Stratégie de tests (dès le départ, pas en fin de projet)

| Niveau | Portée | Outil |
|---|---|---|
| Unitaire | `usecases`, logique de génération de matricule, calculs financiers, transitions de statut | `flutter_test` + `mocktail` |
| Repository | Repository + datasource drift, avec base en mémoire | `drift`'s `NativeDatabase.memory()` |
| Widget | Composants du design system (badges de statut, formulaires) | `flutter_test` |
| Intégration | Parcours complets (créer membre → pointer présence → encaisser) | `integration_test` |

**Règle** : aucun `usecase` du module Finances n'est mergé sans test unitaire couvrant au moins un cas limite (montant négatif, devise différente, transaction annulée).

---

## 7. Prochaine étape concrète

Avant de passer à l'Étape 2 (Design System), le critère de validation de l'Étape 1 exige une **preuve de concept fonctionnelle** :
- Squelette du projet Flutter avec l'arborescence ci-dessus.
- Table `members` définie en `drift` (schéma issu de l'Étape 0).
- Un test unitaire passant (ex. génération de matricule `RTC-2026-0001`).
