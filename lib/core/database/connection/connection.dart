/// Sélectionne l'implémentation de connexion à la base de données selon
/// la plateforme cible, au moment de la compilation — pas à l'exécution.
/// C'est ce qui permet à `dart:io` de rester totalement absent du build
/// Web (import conditionnel, pattern standard du langage Dart).
export 'connection_stub.dart'
    if (dart.library.io) 'connection_io.dart'
    if (dart.library.html) 'connection_web.dart';
