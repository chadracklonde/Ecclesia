import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';

class LocalSubgroupDataSource {
  final AppDatabase db;

  LocalSubgroupDataSource(this.db);

  Future<void> insertSubgroup(SubgroupsCompanion companion) {
    return db.into(db.subgroups).insert(companion);
  }

  Future<SubgroupRow?> getSubgroupById(String id) {
    return (db.select(db.subgroups)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<SubgroupRow>> getAllSubgroups(String churchId) {
    return (db.select(db.subgroups)
          ..where(
              (s) => s.churchId.equals(churchId) & s.isDeleted.equals(false)))
        .get();
  }

  Future<void> assignMember({
    required String memberId,
    required String subgroupId,
    required String roleInGroup,
  }) {
    return db.into(db.memberSubgroups).insertOnConflictUpdate(
          MemberSubgroupsCompanion.insert(
            memberId: memberId,
            subgroupId: subgroupId,
            roleInGroup: Value(roleInGroup),
          ),
        );
  }

  Future<void> removeMember({
    required String memberId,
    required String subgroupId,
  }) {
    return (db.delete(db.memberSubgroups)
          ..where((ms) =>
              ms.memberId.equals(memberId) & ms.subgroupId.equals(subgroupId)))
        .go();
  }

  Future<List<String>> getSubgroupIdsForMember(String memberId) async {
    final rows = await (db.select(db.memberSubgroups)
          ..where((ms) => ms.memberId.equals(memberId)))
        .get();
    return rows.map((r) => r.subgroupId).toList();
  }

  Future<List<String>> getMemberIdsForSubgroup(String subgroupId) async {
    final rows = await (db.select(db.memberSubgroups)
          ..where((ms) => ms.subgroupId.equals(subgroupId)))
        .get();
    return rows.map((r) => r.memberId).toList();
  }
}
