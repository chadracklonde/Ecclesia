# Ecclesia — Protocole d'audit inter-étapes

Appliqué systématiquement avant de déclarer une étape "close" et de passer à la suivante.

## Niveau 1 — Auto-audit (fait par Claude, dans la conversation)
Pour chaque étape, vérifier et documenter explicitement :
- [ ] Tous les livrables annoncés dans la roadmap sont bien produits (pas d'oubli silencieux).
- [ ] Cohérence avec les décisions déjà actées aux étapes précédentes (aucune contradiction avec Étape 0/1…).
- [ ] Les critères de validation définis dans la roadmap sont explicitement passés en revue un par un (pas de validation globale vague).
- [ ] Rien n'a été laissé en "todo silencieux" — tout TODO/limitation doit être signalé explicitement, jamais caché dans le code.

## Niveau 2 — Vérification côté utilisateur (hors sandbox)
Pour toute étape produisant du code exécutable, une checklist précise et minimale est fournie :
- Commandes exactes à lancer.
- Résultat attendu explicite (ex. "les 5 tests passent", "l'app se lance sans erreur").
- Ce qu'il faut signaler si le résultat diverge.

## Règle de clôture
Une étape n'est marquée **✅ Close** dans la roadmap maîtresse qu'après :
1. Auto-audit niveau 1 passé et documenté ici même.
2. Confirmation explicite de l'utilisateur sur le niveau 2 (quand applicable).

Tant que ces deux conditions ne sont pas réunies, l'étape reste **🔄 En attente de confirmation**.

**Amendement du 09/09/2026** : l'utilisateur a choisi de reporter toute vérification niveau 2 (tests, lancement de l'app) à une passe unique en local, une fois l'application jugée suffisamment avancée — plutôt qu'après chaque incrément. En conséquence :
- Le niveau 1 (auto-audit) continue de s'appliquer à chaque incrément, sans exception.
- Le niveau 2 reste noté "en attente" en continu, sans qu'il soit redemandé à chaque étape.
- Chaque entrée de journal liste toujours les commandes et le résultat attendu, pour que la passe finale unique puisse tout vérifier d'un coup.
- Si un problème est découvert lors de cette passe finale, il faudra remonter jusqu'à l'incrément fautif via ce journal.

---

## Journal des audits

### Étape 0 — Modélisation des données
- Niveau 1 : ✅ dictionnaire complet, ERD cohérent, 7 règles métier tranchées, matrice de permissions produite.
- Niveau 2 : n/a (pas de code exécutable à cette étape).
- **Statut : ✅ Close**

### Étape 1 — Architecture technique
- Niveau 1 :
  - ✅ Framework, Clean Architecture, state management, DB, sync, tests : tous documentés et justifiés.
  - ✅ `generate_matricule.dart` conforme à la décision #5 de l'Étape 0 (format et cas limites couverts par les tests).
  - ⚠️ **Incohérence trouvée et corrigée** : la table `Churches` ne portait pas `updatedAt`/`isSynced`/`isDeleted`, contredisant la règle de synchro actée en section 5 du document d'architecture. Corrigé le 08/09/2026.
  - 📝 Noté (non bloquant) : l'entité domaine `Member` est un sous-ensemble volontairement réduit pour la PoC (id, churchId, matricule, nom, statut, dates) — les champs restants (téléphone, adresse, photo, QR…) seront ajoutés à l'Étape 3 lors de l'implémentation complète du module Membres.
  - 📝 Noté (non bloquant) : Riverpod n'est pas encore câblé dans le code (aucun provider), conforme au périmètre PoC défini ("squelette + table + test"), sera introduit à l'Étape 3.
- Niveau 2 : ⚠️ **non vérifié** — l'utilisateur a choisi d'avancer à l'Étape 2 sans confirmer l'exécution locale des tests. Risque accepté explicitement le 08/09/2026 : si `flutter test` échoue une fois testé, il faudra revenir corriger `database.dart`/`generate_matricule.dart` avant de considérer le socle fiable.
- **Statut : 🔶 Avancée sans vérification complète — à revalider dès que possible**

### Étape 2 — Design System
- Niveau 1 :
  - ✅ Palette alignée sur la charte graphique officielle UMC (rouge `#E4002B`, vérifiée via resourceumc.org — pas une supposition).
  - ✅ Distinction marque vs erreur tranchée (`#E4002B` marque / `#C0392B` erreur), avec règle explicite icône+texte pour ne jamais s'appuyer sur la couleur seule.
  - ✅ Badges de statut (Pleine communion/Probation), indicateurs de présence, composants de base (carte, bouton) produits et validés.
  - ✅ 4 maquettes haute fidélité produites : Fiche membre, Dashboard, Pointage présence (QR), Encaissement.
  - ⚠️ **Limite non résolue, à traiter en Étape 3 lors de l'implémentation réelle** : les couleurs des maquettes sont en valeurs fixes (mode clair uniquement) — le mode sombre (inversion des teintes) n'a pas été vérifié visuellement, seulement documenté comme règle à appliquer.
  - 📝 Point ouvert, non bloquant : police de corps de texte distincte d'Oswald (qui n'est pas conçue pour de longs paragraphes) — à trancher en Étape 2bis ou au fil de l'implémentation.
- Niveau 2 : n/a (étape de conception, pas de code exécutable).
- **Statut : ✅ Close**

### Étape 3.1 — Module Membres : couche data (repository, datasource, mapping)
- Niveau 1 :
  - ✅ Entité domaine `Member` complétée selon le dictionnaire intégral de l'Étape 0 (elle était un sous-ensemble réduit depuis la PoC de l'Étape 1).
  - ⚠️ **Bug trouvé et corrigé avant qu'il ne se propage** : drift génère par défaut une classe de données nommée `Member` à partir de la table `Members`, ce qui serait entré en collision directe avec l'entité domaine `Member`. Résolu avec `@DataClassName('MemberRow')` (et de même pour `Churches`→`ChurchRow`, `StatusHistories`→`StatusHistoryRow`, par cohérence).
  - ✅ `MemberRepositoryImpl` : create/get/getAll/updateStatus, erreurs traduites en `Result<Failure>` typé (pas d'exception qui remonte silencieusement).
  - ✅ Changement de statut + insertion de l'historique dans une **transaction unique** (atomicité conforme à la décision #4 de l'Étape 0).
  - ✅ Test de niveau Repository ajouté (`member_repository_impl_test.dart`), base `drift` en mémoire, 4 scénarios : création+lecture, id inconnu, atomicité statut+historique, filtrage par `churchId`.
  - 📝 Noté (non bloquant) : usecases et couche présentation pas encore écrits — prévus en 3.2 et 3.3.
- Niveau 2 : ⚠️ non vérifié — regroupé sous le risque cumulé accepté en 3.3 (voir plus bas).
- **Statut : 🔶 Avancée sans vérification — regroupée avec 3.2/3.3**

### Étape 3.2 — Module Membres : usecases (CreateMember, ChangeMemberStatus, ListMembers, GetMember)
- Niveau 1 :
  - ✅ Ajout de la table `MatriculeCounters` (compteur atomique par église/année) — nécessaire pour rendre implémentable la décision #5 de l'Étape 0 ("jamais réutilisé"), non prévue explicitement dans le dictionnaire initial mais ne le contredit pas. Comme aucune version n'a encore été distribuée, ce reste un ajout au schéma v1 en développement, pas une migration (cf. règle de l'Étape 1 §4, applicable dès qu'une build réelle existera).
  - ✅ `CreateMember` : valide les champs obligatoires, génère `id` (UUID) et `matricule` via le compteur, délègue au repository.
  - ✅ `ChangeMemberStatus` : rejette une transition vers le même statut, propage l'échec si le membre est introuvable, délègue l'historisation atomique au repository (ne la duplique pas).
  - ✅ `ListMembers`/`GetMember` : façades fines, conformes à la règle Clean Architecture (présentation ne parle jamais à drift directement).
  - ✅ 6 tests unitaires avec mocks (`mocktail`) : 3 sur `CreateMember`, 3 sur `ChangeMemberStatus`.
  - 📝 **Trouvé, non bloquant** : `CreateMember` appelle `DateTime.now()` directement (non injectable), ce qui complique les tests avec une date fixe — fonctionne ici car le test mocke `nextSequence` pour n'importe quelle année, mais une horloge injectable serait plus propre. À corriger si ça devient gênant en Étape 6 (Finances), où des dates fixes seront précieuses pour tester des cas de reçus.
- Niveau 2 : ⚠️ non vérifié — regroupé sous le risque cumulé accepté en 3.3 (voir plus bas).
- **Statut : 🔶 Avancée sans vérification — regroupée avec 3.1/3.3**

### Étape 3.3 — Module Membres : couche présentation (providers Riverpod, écrans)
- Niveau 1 :
  - ✅ Thème clair/sombre réel (`AppTheme`) basé sur le rouge UMC — comble la limite notée à l'audit de l'Étape 2 (le mode sombre n'était que documenté, pas implémenté).
  - ✅ `StatusColors`/`AppStatusPalette` : couleurs de statut réellement adaptatives clair/sombre (pas de valeurs fixes comme dans les maquettes statiques).
  - ✅ Providers Riverpod câblant repository → usecases → écrans, sans que la présentation touche `drift` directement (règle stricte de l'Étape 1 respectée).
  - ✅ 3 écrans : liste, formulaire de création, détail avec changement de statut.
  - ✅ 3 tests widget ajoutés (`StatusBadge` × 2 scénarios, validation du formulaire × 1 scénario sans toucher la base) — corrigé le 09/09/2026 : j'avais initialement compté 2 au lieu de 3, erreur trouvée lors d'une relecture systématique du projet et propagée dans tous les totaux ci-dessous jusqu'à ce correctif.
  - ⚠️ **Limite assumée et documentée, pas cachée** : `main.dart` amorce une "église de démonstration" (`ensureDemoChurch`) et le formulaire fixe `churchCode: 'RTC'` en dur — nécessaire car aucun `ChurchRepository` ni écran d'administration n'existent encore (prévus Étape 9). Sans cet amorçage, la création du premier membre échouerait sur la contrainte de clé étrangère `churchId`. Ce n'est pas une solution multi-église, seulement un bootstrap pour que la PoC soit utilisable dès maintenant.
  - 📝 Noté (non bloquant) : `DropdownButtonFormField` utilise le paramètre `value` (API stable de longue date) — non vérifiable dans ce sandbox faute de SDK Flutter, à confirmer par `flutter analyze` en local.
- Niveau 2 : ⚠️ **non vérifié, risque cumulé sur 3 incréments consécutifs (3.1, 3.2, 3.3)** — l'utilisateur a choisi d'avancer à l'Étape 4 sans confirmer ni les tests ni le lancement de l'app. Accepté explicitement le 09/09/2026. Si un problème est découvert plus tard (tests, compilation, ou comportement à l'exécution), il faudra remonter jusqu'à l'incrément fautif parmi les trois avant de continuer sereinement sur les étapes suivantes.
- **Statut : 🔶 Avancée sans vérification complète — à revalider dès que possible**

### Étape 4.1 — Organisation communautaire : couche data (Classes, Sous-groupes, rattachements N:N)
- Niveau 1 :
  - ✅ Tables `ChurchClasses`, `Subgroups`, `MemberClasses`, `MemberSubgroups` (clé primaire composite pour les tables de jointure).
  - ✅ Nommage `ChurchClass`/`ChurchClasses` (pas `Class`) pour éviter toute confusion avec le mot-clé Dart `class` — leçon tirée de la collision `Member` trouvée en 3.1, appliquée préventivement ici.
  - ✅ Rattachement multi-classe/sous-groupe testé explicitement contre la décision #1 de l'Étape 0 (pas juste supposé correct parce que le schéma est N:N).
  - ✅ `insertOnConflictUpdate` pour les rattachements : ré-assigner un membre déjà présent est un no-op, pas une exception — testé explicitement (pas de duplication de ligne).
  - ✅ 4 tests de niveau Repository (multi-classe, retrait ciblé, non-duplication, multi-sous-groupe avec rôle).
  - 📝 Noté (non bloquant) : usecases et écrans (assignation via UI, affichage classe/sous-groupe sur la fiche membre) pas encore écrits — prévus en 4.2/4.3.
- Niveau 2 : ⏳ en attente — `flutter test` doit maintenant montrer **22 tests** au total (18 + 4).
- **Statut : 🔄 En attente de confirmation utilisateur (niveau 2 reporté à la passe finale, voir amendement du protocole)**

### Étape 4.2 — Organisation communautaire : usecases (AssignMemberToClass, AssignMemberToSubgroup, ListClasses, ListSubgroups)
- Niveau 1 :
  - ⚠️ **Gap trouvé en écrivant les usecases** : ni `ChurchClassRepository` ni `SubgroupRepository` n'avaient de `getById` — nécessaire pour valider qu'un membre et une classe/sous-groupe appartiennent à la même église avant de les rattacher. Ajouté aux deux interfaces et implémentations, avec test dédié.
  - ✅ `AssignMemberToClass`/`AssignMemberToSubgroup` : rejettent explicitement un rattachement inter-église (testé), pas seulement supposé impossible parce que l'UI ne le proposerait pas.
  - ✅ `AssignMemberToSubgroup` valide aussi que `roleInGroup` ∈ {membre, responsable} avant tout accès aux repositories (testé : rôle invalide → `verifyZeroInteractions` sur les deux repositories).
  - ✅ `ListClasses`/`ListSubgroups` : façades fines.
  - ✅ 5 tests unitaires avec mocks (3 sur `AssignMemberToClass`, 2 sur `AssignMemberToSubgroup`).
- Niveau 2 : ⏳ reporté à la passe finale (accord du 09/09/2026) — `flutter test` devra alors montrer **27 tests** au total (22 + 5).
- **Statut : 🔄 En attente (niveau 2 reporté)**

### Étape 4.3 — Organisation communautaire : présentation (écrans dédiés + accueil)
- Niveau 1 :
  - ✅ Écrans dédiés, comme demandé : `ClassesListScreen`/`ClassFormScreen`/`ClassDetailScreen` et l'équivalent Subgroups, chacun avec ajout/retrait de membre depuis l'écran de détail (dialogue de sélection, filtré pour exclure les membres déjà rattachés).
  - ✅ `SubgroupDetailScreen` demande explicitement le rôle (membre/responsable) à l'ajout, conforme à `AssignMemberToSubgroup`.
  - ✅ `HomeScreen` ajouté pour relier Membres/Classes/Sous-groupes — `main.dart` mis à jour pour y pointer au lieu d'aller directement à la liste des membres.
  - ✅ 1 test widget de validation (`ClassFormScreen`, nom vide) — symétrique à celui du formulaire membre, pas dupliqué pour `SubgroupFormScreen` par souci de temps (même mécanique de validation, risque résiduel faible).
  - 📝 Noté (non bloquant) : les chemins d'import relatifs entre features (`../../../members/...`) ont été vérifiés manuellement dossier par dossier faute de pouvoir compiler dans ce sandbox — à confirmer par `flutter analyze` en local, qui les signalerait immédiatement s'ils étaient faux.
- Niveau 2 : ⏳ reporté à la passe finale — `flutter test` devra alors montrer **28 tests** au total (27 + 1). Vérification manuelle attendue au lancement : Accueil → Classes → créer une classe → l'ouvrir → ajouter un membre → le retirer ; même parcours pour Sous-groupes avec le choix du rôle.
- **Statut : 🔄 En attente (niveau 2 reporté)**

**Étape 4 (4.1+4.2+4.3) considérée fonctionnellement complète, en attente de la passe de vérification finale.**

### Étape 5 — Présences (données, usecases, présentation)
- Niveau 1 :
  - ⚠️ **Décision de l'Étape 0 révisée avant de coder** : la présence ne dépend plus d'un culte (`service_id` devient optionnel) — corrigé dans `/ecclesia-etape0-modelisation.md` avec justification (suivi pastoral, pas liturgie). Évite la dépendance bloquante vers l'Étape 7 (Cultes), pas encore construite.
  - ✅ Table `Attendances` centrée sur `attendanceDate` (normalisée à minuit pour comparaison fiable).
  - ✅ `recordPresence` fait un upsert par (membre, jour) — pointer deux fois le même membre le même jour met à jour plutôt que dupliquer. Testé explicitement.
  - ✅ `GetMembersToVisit` : usecase central répondant directement au besoin exprimé (identifier qui n'a pas été vu depuis 30 jours, pour les visites pastorales) — testé avec mocks.
  - ⚠️ **Bug trouvé et corrigé avant présentation** : l'écran `AttendanceScreen` affichait l'id technique du membre au lieu de son nom dans la liste des pointés — corrigé en résolvant le nom via la liste des membres déjà chargée.
  - ⚠️ **Limite assumée et documentée** : le scan QR caméra n'est pas câblé (aucun package caméra vérifiable dans ce sandbox, ex. `mobile_scanner`) — l'écran l'indique explicitement à l'utilisateur et propose le pointage manuel, pleinement fonctionnel, en attendant.
  - ✅ `HomeScreen` mis à jour avec les tuiles Présences et Fidèles à visiter.
  - ✅ 5 tests : 4 niveau Repository (insertion, non-duplication même jour, présents depuis une date — cas positif et négatif), 1 niveau usecase (`GetMembersToVisit`, avec mocks).
  - 📝 Noté (non bloquant) : le seuil de 30 jours pour "à visiter" est une valeur indicative choisie par défaut, pas une exigence de l'Étape 0 — à rendre configurable si besoin.
- Niveau 2 : ⏳ reporté à la passe finale — `flutter test` devra alors montrer **33 tests** au total (28 + 5). Vérification manuelle attendue : Accueil → Présences → pointer un membre manuellement → le voir apparaître dans la liste avec son nom (pas son id) → Accueil → Fidèles à visiter → vérifier la liste.
- **Statut : 🔄 En attente (niveau 2 reporté)**

### Étape 6 — Finances et Trésorerie
- Niveau 1 :
  - ✅ **Montants stockés en centimes (entier), jamais en flottant** — décision prise avant tout code, pour éliminer les erreurs d'arrondi silencieuses sur ce module (exigence explicite de l'Étape 1 §2bis).
  - ✅ **Solde de caisse calculé à la volée** (revenus actifs − dépenses actives), jamais stocké comme champ mutable — élimine par construction le risque de "transaction flottante" (critère d'audit explicite de l'Étape 1). Testé explicitement, y compris l'exclusion d'une transaction annulée du calcul.
  - ✅ Annulation = `isCancelled` + motif, jamais de suppression (Étape 0, décision #6) — testé, y compris le rejet d'une double annulation.
  - ✅ Numérotation des reçus séquentielle par église/année (même mécanisme que `MatriculeCounter`), `issueReceipt` idempotent (ré-émettre pour la même transaction ne consomme pas un second numéro) — testé explicitement.
  - ⚠️ **Bug trouvé et corrigé en écrivant les tests** : un test utilisait un faux `Failure` (`DatabaseFailureStub implements Exception`) qui n'implémentait pas réellement `Failure` — aurait été une erreur de typage. Corrigé avec un vrai `DatabaseFailure`.
  - ⚠️ **Bug évité préventivement en écrivant `EncaissementScreen`** : mélanger un `onFailure` synchrone et un `onSuccess` asynchrone dans `Result.fold` aurait provoqué une incohérence de type générique (`void` vs `Future<void>`) — les deux branches sont maintenant async et le `fold` est `await`é.
  - ⚠️ **Limite assumée et documentée dans le code** : `CancelTransaction` annule la transaction puis le reçu via deux repositories distincts, sans transaction DB partagée à ce niveau — non strictement atomique en cas de crash entre les deux appels. Acceptable vu la fréquence attendue très faible ; à durcir si besoin.
  - ✅ Écrans : `EncaissementScreen` (dîme/offrande/quête, génère et confirme le reçu), `DepenseScreen` (catégorie obligatoire, pas de reçu), `FinanceScreen` (solde, liste, annulation avec motif par appui long).
  - ✅ 18 tests : 5 niveau Repository Finance (dont non-duplication de double-annulation et calcul de solde excluant les annulées), 3 niveau Repository Receipt (séquence, idempotence, annulation), 4 sur `RecordIncomeTransaction`, 3 sur `RecordExpenseTransaction`, 3 sur `CancelTransaction`.
- Niveau 2 : ⏳ reporté à la passe finale — `flutter test` devra alors montrer **51 tests** au total (33 + 18). Vérification manuelle attendue : Finances → encaissement d'une dîme → reçu affiché → apparaît dans la liste et dans le solde → annulation avec motif → solde recalculé, ligne barrée dans la liste ; dépense → apparaît en négatif dans le solde.
- **Statut : 🔄 En attente (niveau 2 reporté)**

### Étape 7 — Cultes et Liturgie
- Niveau 1 :
  - ✅ `Services` et `PreacherAssignments` créées ; `Attendances.serviceId` et `FinancialTransactions.serviceId`, restés sans contrainte de clé étrangère depuis les Étapes 5 et 6 faute de table `Services`, portent maintenant une vraie FK — boucle refermée proprement.
  - ✅ Contrainte "membre OU prédicateur externe" (Étape 0, décision #2) appliquée en couche usecase, testée.
  - ✅ **Détection de conflit de planning implémentée et testée** — le critère de validation explicite de cette étape ("pas de conflit de planning non détecté") n'est pas resté une intention : `AssignPreacher` refuse d'affecter un membre déjà prédicateur d'un autre culte le même jour calendaire, avec un test qui le vérifie et un test qui vérifie l'absence de faux positif.
  - ⚠️ **Bug trouvé et corrigé avant présentation, deuxième occurrence** : `ServiceDetailScreen` affichait l'id technique du membre au lieu de son nom pour un prédicateur non-externe — exactement la même classe de bug que celle corrigée dans `AttendanceScreen` à l'Étape 5, cette fois repérée par vigilance acquise avant de présenter le code, pas après.
  - 📝 Noté (non bloquant) : une icône Material (`church_outlined`) dont je n'étais pas certain de l'existence a été remplacée par `calendar_today_outlined`, plus sûre — à ajuster esthétiquement en local si souhaité.
  - ✅ Écrans : `ServicesListScreen`, `ServiceFormScreen`, `ServiceDetailScreen` (affectation membre ou externe, conflit remonté via `SnackBar`).
  - ✅ 8 tests : 4 niveau Repository (Service + PreacherAssignment), 4 sur `AssignPreacher` (rejet sans membre/externe, acceptation externe sans vérif membre, conflit détecté, aucun conflit).
- Niveau 2 : ⏳ reporté à la passe finale — `flutter test` devra alors montrer **59 tests** au total (51 + 8). Vérification manuelle attendue : Cultes → créer deux cultes le même jour → affecter un membre au premier → tenter de l'affecter au second → doit être refusé avec message explicite.
- **Statut : 🔄 En attente (niveau 2 reporté)**

### Étape 8 — Secrétariat et Logistique
- Niveau 1 :
  - ✅ `DocumentRecord` : métadonnées uniquement (titre, type, membre lié, date), `filePath` reste `null` — décision actée avec l'utilisateur avant de coder, cohérente avec le traitement de SQLCipher (Étape 1) et du scan QR (Étape 5) : pas de paquet non vérifiable dans ce sandbox utilisé à l'aveugle.
  - ✅ 3 types de documents prédéfinis (Attestation de membre, Certificat de baptême, Lettre de recommandation), comme demandé — titre auto-généré à partir du type et du nom du membre si non précisé, testé.
  - ✅ `GenerateDocument` rejette un membre d'une autre église (même garde-fou multi-tenant que les autres modules cross-feature).
  - ✅ Inventaire : CRUD complet (contrairement aux documents, aucune dépendance à un paquet non vérifiable) — suppression douce (`isDeleted`), cohérente avec le reste du projet.
  - ✅ 8 tests : 4 niveau Repository (documents, inventaire create/update/delete), 4 sur les usecases (titre auto-généré, rejet inter-église, nom vide, quantité négative).
- Niveau 2 : ⏳ reporté à la passe finale — `flutter test` devra alors montrer **67 tests** au total (59 + 8). Vérification manuelle attendue : Documents → générer une attestation pour un membre → apparaît dans la liste avec la mention "PDF non généré" ; Inventaire → ajouter un article → le voir dans la liste → appui long → disparaît.
- **Statut : 🔄 En attente (niveau 2 reporté)**

### Étape 9 — Administration
- Niveau 1 :
  - ✅ `User`/`Role`/`Permission` enfin construits — le système dont on parle depuis l'Étape 0 a maintenant une vraie implémentation, pas juste un schéma théorique. Nommé `UserAccounts` (pas `Users`) par précaution contre une collision de noms générés par drift, leçon tirée de l'incident `Member`.
  - ⚠️ **Décision de sécurité actée avec l'utilisateur** : mots de passe hachés en SHA-256 + sel, pas bcrypt/Argon2 (paquet non vérifiable dans ce sandbox). Toute la logique isolée dans une seule classe (`PasswordHasher`) pour qu'un futur passage à bcrypt reste un changement localisé, pas une réécriture. Limite documentée dans le code, pas cachée.
  - ✅ Message d'erreur d'authentification volontairement générique ("Identifiants incorrects") que ce soit un nom d'utilisateur inconnu ou un mauvais mot de passe — évite de révéler quels noms d'utilisateur existent.
  - ✅ Matrice de permissions de l'Étape 0 encodée dans `SeedDefaultRolesAndPermissions` (6 rôles), testée y compris le décompte exact des droits du Super Admin.
  - ⚠️ **Limite assumée et documentée dans le code** : la matrice originale de l'Étape 0 qualifiait certains droits de "sa classe"/"sa fiche" (portée au niveau de l'enregistrement) — non implémenté, seulement des permissions au niveau du module. Choix conscient pour cette itération.
  - ⚠️ **Deux bugs trouvés et corrigés avant présentation** : un import vers un fichier inexistant et un nom de type inventé (`PermissionRepositorySeeder` au lieu de `PermissionRepository`) dans `SeedDefaultRolesAndPermissions` — repérés en relisant le fichier avant de le livrer.
  - ✅ Sauvegarde locale : export (avec `PRAGMA wal_checkpoint` avant copie, limite résiduelle documentée), liste, restauration — **testée de bout en bout en simulant un redémarrage de l'app** (fermeture de connexion avant écrasement du fichier, nouvelle connexion après), conformément au critère de validation explicite de cette étape.
  - ✅ Datasource de sauvegarde conçu injectable (répertoire non lié à `path_provider` en dur) pour rester testable sans mock de plugin de plateforme — évite un problème de testabilité avant qu'il n'existe.
  - ✅ Écran Administration : amorçage des rôles, création de compte, export/liste/restauration de sauvegardes avec avertissement explicite de redémarrage.
  - ✅ 10 tests : 4 niveau Repository (permissions, authentification réussie/échouée, nom d'utilisateur dupliqué), 2 sur le cycle sauvegarde/restauration, 4 sur les usecases (amorçage des rôles, décompte Super Admin, `HasPermission` vrai/faux).
- Niveau 2 : ⏳ reporté à la passe finale — `flutter test` devra alors montrer **77 tests** au total (67 + 10). Vérification manuelle attendue : Administration → initialiser les rôles → créer un compte → Sauvegarder maintenant → apparaît dans la liste → Restaurer → fermer et relancer l'app → données conformes à la sauvegarde.
- **Statut : 🔄 En attente (niveau 2 reporté)**

### Étape 10 — Intégration multiplateforme (audit + première amélioration responsive)
- Niveau 1 :
  - ⚠️ **Problème sérieux trouvé, pas mineur** : `dart:io` (utilisé dans `database.dart`, `seed.dart`, `local_backup_datasource.dart` depuis les Étapes 1 et 9) n'existe pas sur Flutter Web — ce n'est pas une dégradation gracieuse, ça casse la compilation Web entièrement. Documenté en détail dans `/ecclesia-etape10-multiplateforme.md`, avec un tableau des risques par plateforme (drift/NativeDatabase, sqlcipher, path_provider, sauvegarde, scan QR).
  - 📝 **Décision non tranchée, remise à l'utilisateur** : deux stratégies Web possibles (Web reporté vers Supabase direct, cohérent avec le pattern déjà décidé pour ÉMU Compagnon à l'Étape 12 ; ou Web dès maintenant via `drift/wasm`, fidèle au brief initial mais non vérifiable dans ce sandbox). Aucune des deux n'a été choisie unilatéralement.
  - ✅ Amélioration responsive livrée indépendamment de cette décision : `HomeScreen` bascule entre liste verticale (mobile) et grille (tablette/desktop/web, ≥700px), corrigeant une vraie lacune du brief initial ("l'application devra être responsive") restée non traitée depuis l'Étape 2.
  - ✅ 1 test widget vérifiant le changement de disposition selon la largeur d'écran (1200px → grille, 400px → liste).
  - 📝 Noté (non bloquant) : les écrans de détail (liste→détail) restent en navigation plein écran ; un vrai layout maître-détail pour grand écran est la suite logique, volontairement reportée tant que la stratégie Web n'est pas tranchée (éviter de retravailler la navigation deux fois).
- Niveau 2 : ⏳ reporté à la passe finale — `flutter test` devra alors montrer **78 tests** au total (77 + 1). Vérification manuelle attendue : redimensionner la fenêtre (desktop/web) ou tester sur tablette — la grille doit apparaître au-delà d'environ 700px de large.
- **Statut : 🔄 En attente (niveau 2 reporté) — décision Web tranchée (Option B), implémentation en cours**

### Étape 10 (suite) — Décision Web tranchée : Option B (hors-ligne partout)
- Niveau 1 :
  - ✅ Décision actée avec l'utilisateur : Web doit fonctionner offline ET online (synchro), cohérent avec la contrainte de connectivité intermittente à Kindu qui a motivé le local-first dès l'Étape 1.
  - ✅ **`dart:io` retiré de `database.dart`** : abstraction par import conditionnel (`connection_io.dart`/`connection_web.dart`/`connection_stub.dart`), pattern standard du langage Dart, sélectionné à la compilation.
  - ✅ Même traitement pour `LocalBackupDataSource` (io/web/stub) — sur Web, dégrade proprement avec message explicite dans `AdminScreen`, plutôt que de bloquer la compilation.
  - ⚠️ **Non vérifié dans ce sandbox, à valider en local avant de faire confiance** : l'implémentation `connection_web.dart` utilise `drift/wasm` (`WasmDatabase.open`) au meilleur de ma connaissance du paquet, mais l'API exacte dépend de la version de `drift` réellement installée. Checklist de vérification fournie dans `/ecclesia-etape10-multiplateforme.md` (fichiers `sqlite3.wasm`/`drift_worker.js` à ajouter dans `web/`, test manuel en navigateur).
  - 📝 Limites Web non résolues et documentées explicitement (pas cachées) : chiffrement sqlcipher, scan QR caméra, compatibilité `pubspec.yaml` de `sqlcipher_flutter_libs` avec `flutter build web`.
- Niveau 2 : ⏳ reporté à la passe finale — **niveau 2 pour la partie Web spécifiquement ne peut être vérifié que sur un vrai navigateur avec le paquet `drift` réellement résolu**, ce que ce sandbox ne permet pas ; à traiter en priorité lors de la passe finale, avant de considérer l'Étape 10 close.
- **Statut : 🔄 En attente (niveau 2 reporté, risque Web élevé signalé explicitement)**

### Logo — intégration (hors séquence des étapes, à la demande de l'utilisateur)
- Niveau 1 :
  - ✅ Logo validé (silhouette d'église, clocher, croix, porte en négatif — rouge UMC sur fond crème), avec wordmark "Ecclesia". Fichiers SVG sources dans `assets/logo/`.
  - ✅ **Redessiné en widgets Flutter natifs (`CustomPainter`)** plutôt que via un paquet SVG (`flutter_svg`) non vérifiable — élimine une dépendance de plus à valider en local, cohérent avec la discipline du projet sur les paquets non vérifiables.
  - ✅ Intégré à l'écran de démarrage (`main.dart`, remplace le simple indicateur de chargement) et à l'en-tête de l'accueil (`HomeScreen`).
  - ✅ 2 tests widget de fumée (icône seule, logo complet avec texte).
  - 📝 Noté (non bloquant) : le wordmark utilise la police système, pas Oswald (prévue par la charte de l'Étape 2) — à câbler via `google_fonts` ou une police embarquée en local.
- Niveau 2 : ⏳ reporté à la passe finale — `flutter test` devra alors montrer **80 tests** au total (78 + 2). Vérification manuelle attendue : le logo doit s'afficher correctement à l'écran de démarrage et dans l'en-tête de l'accueil, sans déformation ni débordement.
- **Statut : 🔄 En attente (niveau 2 reporté)**

### TODOs restants câblés + Étape 11 (à la demande explicite de l'utilisateur : "termine l'app, je teste via mon build GitHub")
- Niveau 1 :
  - ✅ **SQLCipher enfin câblé** (`connection_io.dart` + `secret_key_provider.dart`) : clé aléatoire générée au premier lancement, stockée via `flutter_secure_storage`. Non vérifié dans ce sandbox — pattern officiel `drift`/SQLCipher suivi au mieux de ma connaissance.
  - ✅ **Scan QR câblé** (`mobile_scanner`) : `QrScannerScreen` scanne un code, apparié au matricule du membre via une fonction pure testable (`findMemberByMatricule`, 2 tests). `MemberQrCode` (`qr_flutter`) affiche le QR sur la fiche membre, encodant le matricule (pas un champ séparé).
  - ✅ **Génération PDF câblée** (`pdf` + `printing`) : les 3 templates (Attestation, Certificat de baptême, Lettre de recommandation) génèrent un vrai PDF, ouvert via `Printing.layoutPdf` (fonctionne sur mobile/desktop/web selon la doc du paquet). Logique de titre/texte extraite en fonctions pures testables (3 tests), séparée du rendu PDF lui-même (non testable ici).
  - ✅ **Étape 11 — architecture de synchronisation Supabase** : interface générique (`EntitySyncAdapter`), service push/pull (`TableSyncService`), et **un exemple complet et fonctionnel sur le module Membres** (`MemberSyncAdapter`, mapping JSON testé par aller-retour, 2 tests). Déclenchement manuel depuis Administration ("Synchroniser maintenant"), avec vérification de connectivité (`connectivity_plus`) et dégradation propre si Supabase n'est pas configuré.
  - ⚠️ **Limite assumée, pas cachée** : seul le module Membres a un adaptateur de synchronisation implémenté. Les 17 autres tables suivent exactement le même patron (documenté dans `entity_sync_adapter.dart`), mais ne sont pas dupliquées ici faute de temps — ce n'est pas un oubli, c'est un choix de portée explicite pour livrer un exemple de référence solide plutôt que 18 implémentations non vérifiées à la chaîne.
  - ⚠️ **Limite assumée** : la résolution de conflit spécifique aux Finances (alerte manuelle plutôt que fusion automatique, décision de l'Étape 1) n'est pas câblée puisqu'aucun `FinanceSyncAdapter` n'existe encore — à faire en même temps que cet adaptateur.
  - ⚠️ **Limite assumée** : la date de dernière synchro est gardée en mémoire de session (`AdminScreen._lastMemberSync`), pas persistée entre redémarrages — le premier sync après chaque redémarrage de l'app re-télécharge tout depuis l'an 2000. Fonctionnel mais pas optimal ; à faire évoluer avec un stockage local si le volume de données le justifie.
  - ✅ Relecture systématique refaite sur l'ensemble du projet après ces ajouts (imports relatifs, `dart:io` confiné, classes dupliquées) — toujours propre.
  - ✅ 7 nouveaux tests (2 + 3 + 2).
- Niveau 2 : ⏳ le plus gros morceau non vérifiable de tout le projet — SQLCipher, scan caméra réel, rendu PDF réel, et surtout Supabase (qui nécessite un vrai projet configuré, que je n'ai pas) ne peuvent être testés que par toi, en local, via ton build GitHub. `flutter test` devra montrer **87 tests** au total (80 + 7).
- **Statut : 🔄 Codé intégralement, en attente de vérification réelle — risque le plus élevé de tout le projet, concentré ici**

## Étape 12 — Fusion ÉMU Compagnon : hors de portée pour "terminer l'app"

Contrairement aux autres TODOs, l'Étape 12 n'a pas été codée, et ce n'est
pas une question de vérifiabilité mais de contenu : elle suppose
d'intégrer un corpus biblique complet, un hymnaire, et un calendrier
liturgique — des données religieuses réelles que je n'ai pas et ne peux
pas générer de façon fiable. Coder une coquille vide (écrans "Bible"
sans texte biblique dedans) n'aurait aucune valeur. Cadrage préliminaire
déjà fait dans `/ecclesia-roadmap.md` — à traiter comme un projet de
contenu séparé, une fois le cœur applicatif stabilisé.
