import 'package:drift/drift.dart';

import 'connection/connection.dart' as connection;

part 'database.g.dart';

// ---------------------------------------------------------------------------
// Church — racine multi-tenant (Étape 0). Une seule ligne en usage actuel,
// mais toute future extension multi-paroisses n'exige aucune migration
// structurelle grâce au `churchId` déjà présent sur les tables métier.
// ---------------------------------------------------------------------------
@DataClassName('ChurchRow')
class Churches extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get code =>
      text().withLength(min: 2, max: 10)(); // ex: RTC — utilisé dans le matricule
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  // Champs de préparation à la synchro Supabase (Étape 11) — cohérent avec
  // la règle actée en Étape 1 §5 : toute table synchronisable porte ces
  // trois champs, Churches ne faisait pas exception (corrigé à l'audit).
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Members — cf. dictionnaire d'entités Étape 0.
// ---------------------------------------------------------------------------
@DataClassName('MemberRow')
class Members extends Table {
  TextColumn get id => text()(); // UUID, pas auto-increment (préparation sync)
  TextColumn get churchId => text().references(Churches, #id)();
  TextColumn get matricule => text().unique()(); // format CODE-ANNÉE-SEQ
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get sex => text()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  TextColumn get qrCodeValue => text().nullable()();
  TextColumn get status => text()(); // 'probation' | 'full_member'
  DateTimeColumn get statusSince => dateTime()();
  DateTimeColumn get joinDate => dateTime()();
  TextColumn get maritalStatus => text().nullable()();
  TextColumn get profession => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  // Champs de préparation à la synchro Supabase (Étape 11) :
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// StatusHistory — traçabilité intégrale des transitions de statut.
// Jamais écrasée, uniquement complétée (Étape 0, décision #4).
// ---------------------------------------------------------------------------
@DataClassName('StatusHistoryRow')
class StatusHistories extends Table {
  TextColumn get id => text()();
  TextColumn get memberId => text().references(Members, #id)();
  TextColumn get oldStatus => text()();
  TextColumn get newStatus => text()();
  DateTimeColumn get changeDate => dateTime().withDefault(currentDateAndTime)();
  TextColumn get note => text().nullable()();
  TextColumn get recordedBy => text().nullable()(); // user_id, nullable pour import initial

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// MatriculeCounter — compteur persistant par église/année. Détail
// d'implémentation nécessaire pour garantir la décision #5 de l'Étape 0
// (un matricule n'est jamais réutilisé) : on incrémente un compteur dédié
// plutôt que de calculer un MAX/COUNT sur les membres existants (fragile
// en cas de suppression ou de parsing de chaîne).
// ---------------------------------------------------------------------------
@DataClassName('MatriculeCounterRow')
class MatriculeCounters extends Table {
  TextColumn get id => text()(); // "{churchId}-{year}"
  TextColumn get churchId => text().references(Churches, #id)();
  IntColumn get year => integer()();
  IntColumn get lastSequence => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// ChurchClass — classes wesleyennes (Étape 0). Nommée `ChurchClass` plutôt
// que `Class` pour éviter toute confusion avec le mot-clé Dart `class`.
// ---------------------------------------------------------------------------
@DataClassName('ChurchClassRow')
class ChurchClasses extends Table {
  TextColumn get id => text()();
  TextColumn get churchId => text().references(Churches, #id)();
  TextColumn get name => text()();
  TextColumn get leaderMemberId =>
      text().nullable().references(Members, #id)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Subgroup — sous-groupes (jeunesse, chorale, etc. — Étape 0).
// ---------------------------------------------------------------------------
@DataClassName('SubgroupRow')
class Subgroups extends Table {
  TextColumn get id => text()();
  TextColumn get churchId => text().references(Churches, #id)();
  TextColumn get name => text()();
  TextColumn get type => text()(); // jeunesse, chorale, femmes, hommes...
  TextColumn get leaderMemberId =>
      text().nullable().references(Members, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Rattachements N:N — décision #1 de l'Étape 0 : un membre peut appartenir
// à plusieurs classes/sous-groupes simultanément.
// ---------------------------------------------------------------------------
class MemberClasses extends Table {
  TextColumn get memberId => text().references(Members, #id)();
  TextColumn get classId => text().references(ChurchClasses, #id)();
  DateTimeColumn get dateJoined => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {memberId, classId};
}

class MemberSubgroups extends Table {
  TextColumn get memberId => text().references(Members, #id)();
  TextColumn get subgroupId => text().references(Subgroups, #id)();
  DateTimeColumn get dateJoined => dateTime().withDefault(currentDateAndTime)();
  TextColumn get roleInGroup =>
      text().withDefault(const Constant('membre'))(); // 'membre' | 'responsable'

  @override
  Set<Column> get primaryKey => {memberId, subgroupId};
}

// ---------------------------------------------------------------------------
// Service (Culte) — Étape 7. Son existence permet enfin de donner une
// vraie contrainte de clé étrangère à `Attendances.serviceId` et
// `FinancialTransactions.serviceId`, restés volontairement non contraints
// depuis les Étapes 5 et 6 (Service n'existait pas encore).
// ---------------------------------------------------------------------------
@DataClassName('ServiceRow')
class Services extends Table {
  TextColumn get id => text()();
  TextColumn get churchId => text().references(Churches, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get type => text()(); // 'dominical' | 'special' | 'veillee'
  TextColumn get theme => text().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('planifie'))(); // 'planifie' | 'tenu' | 'annule'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// PreacherAssignment — Étape 0, décision #2 : le prédicateur n'est pas
// nécessairement un membre enregistré. Contrainte "memberId OU
// externalName renseigné" appliquée au niveau usecase (`AssignPreacher`),
// pas en `CHECK` SQL, pour rester cohérent avec les autres validations
// métier de ce projet, toutes faites en couche domaine.
// ---------------------------------------------------------------------------
@DataClassName('PreacherAssignmentRow')
class PreacherAssignments extends Table {
  TextColumn get id => text()();
  TextColumn get serviceId => text().references(Services, #id)();
  TextColumn get memberId => text().nullable().references(Members, #id)();
  TextColumn get externalName => text().nullable()();
  TextColumn get externalContact => text().nullable()();
  TextColumn get role =>
      text().withDefault(const Constant('principal'))(); // 'principal' | 'invite'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Attendance — présence, centrée sur la date plutôt que sur le culte
// (Étape 0, décision #8, révisée le 09/09/2026) : sert d'abord le suivi
// pastoral (identifier qui visiter), pas la liturgie. `serviceId` est
// optionnel — un pointage n'exige jamais qu'un culte existe.
// ---------------------------------------------------------------------------
@DataClassName('AttendanceRow')
class Attendances extends Table {
  TextColumn get id => text()();
  TextColumn get churchId => text().references(Churches, #id)();
  TextColumn get memberId => text().references(Members, #id)();
  TextColumn get serviceId =>
      text().nullable().references(Services, #id)(); // optionnel : la présence ne dépend pas d'un culte (Étape 0, décision #8)
  DateTimeColumn get attendanceDate => dateTime()(); // jour du pointage
  DateTimeColumn get checkInTime => dateTime().nullable()();
  TextColumn get method => text()(); // 'qr_scan' | 'manuel'
  TextColumn get status => text()(); // 'present' | 'absent' | 'retard'
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// FinancialTransaction — Étape 0. Montant stocké en CENTIMES (entier),
// jamais en flottant : un `REAL` pour de l'argent produit des erreurs
// d'arrondi silencieuses, inacceptables sur ce module (cf. Étape 1 §2bis).
// `isCancelled` plutôt que suppression : Étape 0, décision #6, une
// transaction annulée reste visible et traçable, jamais effacée.
// ---------------------------------------------------------------------------
@DataClassName('FinancialTransactionRow')
class FinancialTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get churchId => text().references(Churches, #id)();
  TextColumn get type => text()(); // 'dime' | 'offrande' | 'quete' | 'depense'
  IntColumn get amountCents => integer()();
  TextColumn get currency => text().withDefault(const Constant('CDF'))();
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get memberId => text().nullable().references(Members, #id)();
  TextColumn get serviceId =>
      text().nullable().references(Services, #id)(); // quête éventuellement liée à un culte (Étape 0, décision #3)
  TextColumn get category => text().nullable()(); // catégorie de dépense
  TextColumn get note => text().nullable()();
  TextColumn get recordedBy => text().nullable()();
  BoolColumn get isCancelled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get cancelledAt => dateTime().nullable()();
  TextColumn get cancelledReason => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Receipt — numérotation séquentielle par église, jamais réutilisée,
// même après annulation (Étape 0, décision #6). `isCancelled`, jamais
// de suppression.
// ---------------------------------------------------------------------------
@DataClassName('ReceiptRow')
class Receipts extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId =>
      text().references(FinancialTransactions, #id)();
  TextColumn get receiptNumber => text().unique()();
  DateTimeColumn get issueDate => dateTime().withDefault(currentDateAndTime)();
  TextColumn get issuedBy => text().nullable()();
  BoolColumn get isCancelled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// ReceiptCounter — même mécanisme que MatriculeCounter : compteur
// persistant par église/année, incrémenté dans une transaction, pour
// garantir qu'un numéro de reçu n'est jamais réutilisé ni sauté.
// ---------------------------------------------------------------------------
@DataClassName('ReceiptCounterRow')
class ReceiptCounters extends Table {
  TextColumn get id => text()(); // "{churchId}-{year}"
  TextColumn get churchId => text().references(Churches, #id)();
  IntColumn get year => integer()();
  IntColumn get lastNumber => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// DocumentRecord — Étape 8. Métadonnées du document uniquement pour
// l'instant : `filePath` reste nullable tant que la génération PDF réelle
// n'est pas câblée (décision actée : pas de paquet PDF vérifiable dans ce
// sandbox — cf. TODO explicite dans `GenerateDocument`).
// ---------------------------------------------------------------------------
@DataClassName('DocumentRecordRow')
class DocumentRecords extends Table {
  TextColumn get id => text()();
  TextColumn get churchId => text().references(Churches, #id)();
  TextColumn get templateType =>
      text()(); // 'attestation_membre' | 'certificat_bapteme' | 'lettre_recommandation'
  TextColumn get title => text()();
  DateTimeColumn get generatedDate =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get relatedMemberId =>
      text().nullable().references(Members, #id)();
  TextColumn get filePath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// InventoryItem — Étape 8, inventaire du matériel.
// ---------------------------------------------------------------------------
@DataClassName('InventoryItemRow')
class InventoryItems extends Table {
  TextColumn get id => text()();
  TextColumn get churchId => text().references(Churches, #id)();
  TextColumn get name => text()();
  TextColumn get category => text().nullable()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  TextColumn get condition => text().nullable()();
  TextColumn get location => text().nullable()();
  DateTimeColumn get acquiredDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Role / Permission — Étape 0, matrice de permissions. Nommé
// `UserAccounts` (pas `Users`) pour éviter par avance une collision de
// noms générés par drift, leçon tirée de l'incident `Member` (Étape 3.1).
// ---------------------------------------------------------------------------
@DataClassName('RoleRow')
class Roles extends Table {
  TextColumn get id => text()();
  TextColumn get churchId => text().references(Churches, #id)();
  TextColumn get name =>
      text()(); // 'super_admin' | 'pasteur' | 'tresorier' | 'secretaire' | 'responsable_classe' | 'membre_lecture'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PermissionRow')
class Permissions extends Table {
  TextColumn get id => text()();
  TextColumn get roleId => text().references(Roles, #id)();
  TextColumn get module =>
      text()(); // 'members' | 'finance' | 'attendance' | 'liturgy' | 'secretariat' | 'admin' | 'classes_subgroups'
  TextColumn get action => text()(); // 'create' | 'read' | 'update' | 'delete'

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// UserAccount — compte de connexion, distinct de Membre (Étape 0).
// `passwordHash`/`passwordSalt` : SHA-256 + sel, décision actée le
// 09/09/2026 — voir `PasswordHasher` pour la justification et la limite
// documentée (pas de facteur de coût, à durcir en bcrypt/Argon2 avant
// toute mise en production réelle exposée à un risque de vol d'appareil).
// ---------------------------------------------------------------------------
@DataClassName('UserAccountRow')
class UserAccounts extends Table {
  TextColumn get id => text()();
  TextColumn get churchId => text().references(Churches, #id)();
  TextColumn get username => text().unique()();
  TextColumn get passwordHash => text()();
  TextColumn get passwordSalt => text()();
  TextColumn get memberId => text().nullable().references(Members, #id)();
  TextColumn get roleId => text().references(Roles, #id)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Churches,
  Members,
  StatusHistories,
  MatriculeCounters,
  ChurchClasses,
  Subgroups,
  MemberClasses,
  MemberSubgroups,
  Services,
  PreacherAssignments,
  Attendances,
  FinancialTransactions,
  Receipts,
  ReceiptCounters,
  DocumentRecords,
  InventoryItems,
  Roles,
  Permissions,
  UserAccounts,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        // Les migrations futures se numérotent ici (onUpgrade), chacune
        // testée contre des données existantes avant toute release
        // (cf. Étape 1, section 4 — aucune perte de données tolérée).
      );
}

/// Ouvre la connexion à la base de données locale — l'implémentation
/// réelle (native via `dart:io`, ou Web via `drift/wasm`) est choisie à
/// la compilation par `connection/connection.dart` (Étape 10, décision :
/// Web doit fonctionner hors-ligne comme les autres plateformes). Ce
/// fichier ne connaît plus `dart:io` du tout — c'était la cause de
/// l'échec de compilation Web trouvé lors de l'audit multiplateforme.
QueryExecutor openConnection() {
  return connection.connect();
}
