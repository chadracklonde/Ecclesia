import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';

class LocalMemberDataSource {
  final AppDatabase db;

  LocalMemberDataSource(this.db);

  Future<void> insertMember(MembersCompanion companion) {
    return db.into(db.members).insert(companion);
  }

  Future<MemberRow?> getMemberById(String id) {
    return (db.select(db.members)..where((m) => m.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<MemberRow>> getAllMembersByChurch(String churchId) {
    return (db.select(db.members)
          ..where(
              (m) => m.churchId.equals(churchId) & m.isDeleted.equals(false)))
        .get();
  }

  /// Met à jour le statut du membre et insère la ligne d'historique dans
  /// une transaction unique — l'atomicité garantit qu'on ne se retrouve
  /// jamais avec un statut changé sans trace, ou une trace sans le
  /// changement réel (Étape 0, décision #4).
  Future<MemberRow> updateStatusWithHistory({
    required String memberId,
    required String oldStatus,
    required String newStatus,
    required DateTime changeDate,
    String? note,
    String? recordedBy,
    required String historyId,
  }) async {
    return db.transaction(() async {
      await (db.update(db.members)..where((m) => m.id.equals(memberId)))
          .write(MembersCompanion(
        status: Value(newStatus),
        statusSince: Value(changeDate),
        updatedAt: Value(DateTime.now()),
      ));

      await db.into(db.statusHistories).insert(
            StatusHistoriesCompanion.insert(
              id: historyId,
              memberId: memberId,
              oldStatus: oldStatus,
              newStatus: newStatus,
              note: Value(note),
              recordedBy: Value(recordedBy),
            ),
          );

      return (db.select(db.members)..where((m) => m.id.equals(memberId)))
          .getSingle();
    });
  }
}
