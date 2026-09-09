import '../../../../core/database/database.dart';

class LocalUserAccountDataSource {
  final AppDatabase db;

  LocalUserAccountDataSource(this.db);

  Future<void> insert(UserAccountsCompanion companion) {
    return db.into(db.userAccounts).insert(companion);
  }

  Future<UserAccountRow?> getByUsername(String username) {
    return (db.select(db.userAccounts)..where((u) => u.username.equals(username)))
        .getSingleOrNull();
  }

  Future<List<UserAccountRow>> getForChurch(String churchId) {
    return (db.select(db.userAccounts)..where((u) => u.churchId.equals(churchId)))
        .get();
  }
}
