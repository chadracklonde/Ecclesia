# Ecclesia — Feuille de route maîtresse

Statut au 08/09/2026.

| Étape | Objectif | Statut |
|---|---|---|
| 0 — Modélisation des données | Dictionnaire d'entités, ERD, règles métier, permissions | ✅ Validée |
| 1 — Architecture technique | Flutter, Clean Architecture, Riverpod, drift, tests, sqlcipher | 🔄 En cours — PoC en construction |
| 2 — Design System | Palette clair/sombre, composants, maquettes | ✅ Close |
| 3 — Module Membres et Identités | CRUD, matricule, QR code, statuts | 🔶 Codé (data+usecases+UI), non vérifié |
| 4 — Organisation communautaire | Classes wesleyennes, sous-groupes | 🔶 Codé (data+usecases+UI), non vérifié |
| 5 — Présences | Pointage, QR offline, assiduité | 🔶 Codé, scan QR câblé (mobile_scanner), non vérifié |
| 6 — Finances et Trésorerie | Dîmes, offrandes, quêtes, reçus, caisse | 🔶 Codé (montants en centimes, solde calculé, reçus séquentiels), non vérifié |
| 7 — Cultes et Liturgie | Calendrier, prédicateurs | 🔶 Codé (dont détection de conflit de planning), non vérifié |
| 8 — Secrétariat et Logistique | Documents, inventaire | 🔶 Codé, génération PDF réelle câblée (pdf/printing), non vérifié |
| 9 — Administration | Rôles, accès, sauvegardes locales | 🔶 Codé (User/Role/Permission, sauvegarde testée bout en bout), non vérifié |
| 10 — Intégration multiplateforme | Web/iOS/Android/macOS/Windows, responsive | 🔶 Décision Web actée (offline via drift/wasm), abstraction io/web codée, non vérifiée en navigateur réel |
| 11 — Synchronisation Supabase | Sync cloud, résolution de conflits | 🔶 Architecture + exemple complet (Membres) codés, config Supabase à fournir, non vérifié |
| **12 — Fusion ÉMU Compagnon** | Intégrer Bible, hymnaire, dictionnaire biblique, calendrier liturgique dans Ecclesia | ⏳ Hors de portée pour l'instant — nécessite un corpus de contenu réel, pas juste du code |

## Étape 12 — Fusion ÉMU Compagnon (cadrage préliminaire)

**Objectif** : intégrer dans Ecclesia les fonctionnalités de contenu d'ÉMU Compagnon (Bible, hymnaire, dictionnaire biblique, calendrier liturgique), déjà pensées pour un fonctionnement multiplateforme avec Supabase côté Web et données locales côté Desktop/Mobile.

**Ce que l'architecture actuelle absorbe déjà sans rework** :
- Structure feature-first (`features/bible/`, `features/hymnal/`, `features/liturgical_calendar/`) — s'ajoute sans toucher au reste.
- Stratégie Supabase déjà prévue pour la sync (Étape 11), compatible avec le besoin Web-connecté d'ÉMU Compagnon.

**Points à trancher au moment venu** (non bloquants pour l'instant) :
- Faut-il un compte utilisateur unique (SSO interne) entre "gestion d'église" (rôle Trésorier/Secrétaire/etc.) et le contenu personnel (Bible/hymnaire) d'un membre, ou deux systèmes de comptes distincts ?
- Les trois méthodes de liaison d'appareil d'ÉMU Compagnon (email/mot de passe, lien magique, code à 6 chiffres) s'appliquent-elles aussi aux comptes "gestion d'église", ou seulement au contenu ?
- Faut-il migrer les utilisateurs existants d'ÉMU Compagnon vers Ecclesia, ou les deux apps restent-elles distribuées séparément avec un contenu partagé ?

**Critère de validation** : cadrage détaillé (comme l'Étape 0) mené au moment où cette étape démarre réellement, pas avant.

---

## Décisions transverses déjà actées

- Multi-église : `church_id` présent dès le schéma initial (Étape 0).
- Matricule : format `CODE-ANNÉE-SÉQUENCE`, ex. `RTC-2026-0042`.
- Chiffrement de la base locale : `sqlcipher` activé dès le squelette du projet (pas différé).
- Authentification "gestion d'église" : `Utilisateur` distinct de `Membre`, rôle → permissions par module (déjà couvert par le modèle de l'Étape 0, pas un ajout séparé).
