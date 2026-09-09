import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../../../core/sync/entity_sync_adapter.dart';

/// Exemple de référence pour synchroniser une table locale avec Supabase.
/// Travaille sur `MemberRow` (couche data), pas sur l'entité domaine
/// `Member` — la synchronisation est une préoccupation d'infrastructure,
/// et `MemberRow` porte déjà `updatedAt`/`isSynced`, contrairement à
/// l'entité domaine qui les expose volontairement pas (Étape 3).
///
/// Pour dupliquer ce patron sur une autre table : mêmes 6 méthodes,
/// mêmes noms de colonnes en snake_case côté Supabase (convention SQL
/// standard, à adapter si le schéma Supabase réel diffère).
class MemberSyncAdapter implements EntitySyncAdapter<MemberRow> {
  final AppDatabase db;

  MemberSyncAdapter(this.db);

  @override
  String get tableName => 'members';

  @override
  Future<List<MemberRow>> getUnsyncedLocal() {
    return (db.select(db.members)..where((m) => m.isSynced.equals(false))).get();
  }

  @override
  Future<void> markSynced(String id) {
    return (db.update(db.members)..where((m) => m.id.equals(id))).write(
      const MembersCompanion(isSynced: Value(true)),
    );
  }

  @override
  Map<String, dynamic> toRemoteJson(MemberRow row) {
    return {
      'id': row.id,
      'church_id': row.churchId,
      'matricule': row.matricule,
      'first_name': row.firstName,
      'last_name': row.lastName,
      'sex': row.sex,
      'birth_date': row.birthDate?.toIso8601String(),
      'phone': row.phone,
      'address': row.address,
      'status': row.status,
      'status_since': row.statusSince.toIso8601String(),
      'join_date': row.joinDate.toIso8601String(),
      'marital_status': row.maritalStatus,
      'profession': row.profession,
      'updated_at': DateTime.now().toIso8601String(),
      'is_deleted': row.isDeleted,
    };
  }

  @override
  MemberRow fromRemoteJson(Map<String, dynamic> json) {
    return MemberRow(
      id: json['id'] as String,
      churchId: json['church_id'] as String,
      matricule: json['matricule'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      sex: json['sex'] as String,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      photoPath: null,
      qrCodeValue: null,
      status: json['status'] as String,
      statusSince: DateTime.parse(json['status_since'] as String),
      joinDate: DateTime.parse(json['join_date'] as String),
      maritalStatus: json['marital_status'] as String?,
      profession: json['profession'] as String?,
      createdAt: DateTime.now(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isSynced: true,
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  @override
  Future<void> upsertLocal(MemberRow row) {
    // Last-write-wins par updated_at (Étape 1) : on écrase simplement la
    // ligne locale par la version distante reçue — le tri par date n'a
    // pas besoin d'être refait ici puisque `pull()` ne redemande que les
    // lignes distantes plus récentes que le dernier sync.
    return db.into(db.members).insertOnConflictUpdate(
          row.toCompanion(true),
        );
  }

  @override
  DateTime updatedAtOf(MemberRow row) => row.updatedAt;

  @override
  String idOf(MemberRow row) => row.id;
}
