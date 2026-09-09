# Ecclesia — Guide de vérification finale

Ce document rassemble tout ce qui est éparpillé dans `/ecclesia-audit-protocole.md`
en une seule checklist actionnable. À suivre dans l'ordre.

## 1. Installation

```bash
cd ecclesia_poc
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Si `flutter pub get` échoue sur une version de paquet, ajuste les
contraintes dans `pubspec.yaml` (toutes marquées comme indicatives dans
ce projet, jamais vérifiées contre pub.dev réel).

## 2. Tests automatisés

```bash
flutter test
```

**87 tests attendus.** S'il y en a moins ou plus, quelque chose a changé
depuis la rédaction de ce guide — recompte dans `/ecclesia-audit-protocole.md`
(chaque étape y indique son propre delta).

Si un test échoue, le journal d'audit indique pour chaque étape quel
fichier et quel usecase/repository il couvre — utile pour remonter à la
source.

## 3. Ce qui a changé : les TODOs de sécurité/plateforme sont maintenant câblés

Ces points étaient documentés comme non câblés dans les versions précédentes de ce guide — ils le sont maintenant, mais **aucun n'a pu être vérifié par exécution réelle** (pas de SDK Flutter dans ce sandbox). C'est le plus gros risque résiduel de tout le projet.

| # | Sujet | Où | Statut |
|---|---|---|---|
| 1 | Chiffrement SQLCipher | `core/database/connection/connection_io.dart`, `core/database/secret_key_provider.dart` | Câblé — clé générée et stockée via `flutter_secure_storage` au premier lancement |
| 2 | Scan QR caméra | `attendance/presentation/screens/qr_scanner_screen.dart` (`mobile_scanner`) | Câblé — apparie le code scanné au matricule du membre |
| 3 | Affichage QR sur la fiche membre | `members/presentation/widgets/member_qr_code.dart` (`qr_flutter`) | Câblé |
| 4 | Génération PDF réelle | `secretariat/data/pdf/document_pdf_generator.dart` (`pdf` + `printing`) | Câblé — génère et ouvre un vrai PDF pour les 3 templates |
| 5 | Web : `drift/wasm` | `connection_web.dart` | Câblé (Étape 10), API à vérifier contre la version de `drift` installée, fichiers `sqlite3.wasm`/`drift_worker.js` à ajouter dans `web/` |
| 6 | Web : sauvegarde/restauration | — | Toujours non implémenté (dégrade proprement avec message explicite) |
| 7 | Synchronisation Supabase | `core/sync/`, `features/members/data/sync/member_sync_adapter.dart` | Architecture + exemple complet sur Membres câblés — **nécessite un vrai projet Supabase** : remplir `core/sync/supabase_config.dart` (URL + clé anonyme) avant de tester. Les 17 autres tables suivent le même patron mais ne sont pas encore dupliquées. |
| 8 | Mot de passe SHA-256 (pas bcrypt) | `admin/data/password_hasher.dart` | Acceptable pour l'instant (décision actée), à durcir en bcrypt/Argon2 avant toute exposition à un risque réel de vol d'appareil |

## 4. Parcours de vérification manuelle, par module

Lance l'app (`flutter run`) et suis ce parcours dans l'ordre — chaque
étape dépend souvent de données créées à l'étape précédente.

1. **Accueil** : la grille apparaît en plein écran/fenêtre large, la
   liste verticale sur mobile ou fenêtre étroite. Le logo (icône église
   + nom) doit s'afficher correctement dans l'en-tête, et brièvement en
   grand à l'écran de démarrage.
2. **Membres** : créer un membre → vérifier le matricule généré
   (`RTC-2026-000X`) → ouvrir sa fiche → un QR code doit s'afficher
   (encodant le matricule) → changer son statut.
3. **Classes** : créer une classe → ajouter le membre créé → vérifier
   qu'il peut aussi être ajouté à une seconde classe (multi-classe).
4. **Présences** : "Scanner un QR code" → scanner le QR affiché sur la
   fiche du membre (avec un second appareil, ou une capture d'écran) →
   doit pointer automatiquement le bon membre. Tester aussi le
   pointage manuel en repli.
5. **Fidèles à visiter** : normalement vide juste après un pointage
   (le membre vient d'être vu).
6. **Finances** : encaisser une dîme pour le membre → un reçu
   `REC-2026-0000XX` doit s'afficher → annuler la transaction avec un
   motif → le solde doit se recalculer, la ligne apparaît barrée.
7. **Cultes** : créer deux cultes le même jour → affecter le membre au
   premier comme prédicateur → tenter de l'affecter au second → doit
   être refusé (conflit de planning détecté).
8. **Documents** : générer une "Attestation de membre" pour le membre →
   un vrai PDF doit s'ouvrir (dialogue d'impression/partage du système).
9. **Inventaire** : ajouter un article → le voir dans la liste → appui
   long → disparaît.
10. **Administration** : "Initialiser les rôles par défaut" → créer un
    compte utilisateur avec un rôle → "Sauvegarder maintenant" →
    "Restaurer" → **fermer complètement l'app et la relancer** → les
    données doivent correspondre à l'état au moment de la sauvegarde.
11. **Synchronisation** (nécessite d'avoir rempli `core/sync/supabase_config.dart`
    avec un vrai projet Supabase au préalable) : "Synchroniser
    maintenant" → vérifier dans le tableau `members` de Supabase que le
    membre créé apparaît.

## 5. Limites connues, assumées et documentées dans le code

Ce ne sont pas des oublis — chacune est expliquée en commentaire à
l'endroit concerné, avec le raisonnement :
- Annulation transaction+reçu non strictement atomique (`cancel_transaction.dart`).
- Permissions au niveau du module seulement, pas "sa classe"/"sa fiche" (`seed_default_roles_and_permissions.dart`).
- Export de sauvegarde : `PRAGMA wal_checkpoint` réduit mais n'élimine pas tout risque d'incohérence pendant une écriture concurrente.

## 6. Une fois tout vérifié

Reviens vers moi avec les résultats (tests passés/échoués, parcours
manuel OK/KO) — je mettrai à jour `/ecclesia-audit-protocole.md` pour
clore officiellement chaque étape encore marquée "🔶 non vérifié", et on
pourra enchaîner sereinement sur les Étapes 11 (synchro Supabase) et 12
(fusion ÉMU Compagnon), toutes deux déjà cadrées comme phases futures.
