import '../../../../core/database/database.dart';

class LocalDocumentRecordDataSource {
  final AppDatabase db;

  LocalDocumentRecordDataSource(this.db);

  Future<void> insert(DocumentRecordsCompanion companion) {
    return db.into(db.documentRecords).insert(companion);
  }

  Future<List<DocumentRecordRow>> getForChurch(String churchId) {
    return (db.select(db.documentRecords)
          ..where((d) =>
              d.churchId.equals(churchId) & d.isDeleted.equals(false)))
        .get();
  }
}
