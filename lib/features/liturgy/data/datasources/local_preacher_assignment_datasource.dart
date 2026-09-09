import '../../../../core/database/database.dart';

class LocalPreacherAssignmentDataSource {
  final AppDatabase db;

  LocalPreacherAssignmentDataSource(this.db);

  Future<void> insert(PreacherAssignmentsCompanion companion) {
    return db.into(db.preacherAssignments).insert(companion);
  }

  Future<List<PreacherAssignmentRow>> getForService(String serviceId) {
    return (db.select(db.preacherAssignments)
          ..where((a) => a.serviceId.equals(serviceId)))
        .get();
  }

  Future<void> remove(String id) {
    return (db.delete(db.preacherAssignments)..where((a) => a.id.equals(id)))
        .go();
  }
}
