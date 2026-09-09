import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';

class LocalChurchClassDataSource {
  final AppDatabase db;

  LocalChurchClassDataSource(this.db);

  Future<void> insertClass(ChurchClassesCompanion companion) {
    return db.into(db.churchClasses).insert(companion);
  }

  Future<ChurchClassRow?> getClassById(String id) {
    return (db.select(db.churchClasses)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<ChurchClassRow>> getAllClasses(String churchId) {
    return (db.select(db.churchClasses)
          ..where(
              (c) => c.churchId.equals(churchId) & c.isDeleted.equals(false)))
        .get();
  }

  Future<void> assignMember({
    required String memberId,
    required String classId,
  }) {
    // insertOnConflictUpdate évite une exception si le rattachement existe
    // déjà (ré-assigner un membre déjà membre de la classe est un no-op).
    return db.into(db.memberClasses).insertOnConflictUpdate(
          MemberClassesCompanion.insert(memberId: memberId, classId: classId),
        );
  }

  Future<void> removeMember({
    required String memberId,
    required String classId,
  }) {
    return (db.delete(db.memberClasses)
          ..where((mc) => mc.memberId.equals(memberId) & mc.classId.equals(classId)))
        .go();
  }

  Future<List<String>> getClassIdsForMember(String memberId) async {
    final rows = await (db.select(db.memberClasses)
          ..where((mc) => mc.memberId.equals(memberId)))
        .get();
    return rows.map((r) => r.classId).toList();
  }

  Future<List<String>> getMemberIdsForClass(String classId) async {
    final rows = await (db.select(db.memberClasses)
          ..where((mc) => mc.classId.equals(classId)))
        .get();
    return rows.map((r) => r.memberId).toList();
  }
}
