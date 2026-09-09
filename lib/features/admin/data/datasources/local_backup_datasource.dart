/// Même pattern que `core/database/connection/connection.dart` : choisit
/// l'implémentation à la compilation, garde `dart:io` hors du build Web.
export 'local_backup_datasource_stub.dart'
    if (dart.library.io) 'local_backup_datasource_io.dart'
    if (dart.library.html) 'local_backup_datasource_web.dart';
