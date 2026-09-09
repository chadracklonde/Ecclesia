import '../../../../core/utils/result.dart';

abstract class BackupRepository {
  /// Retourne le chemin du fichier de sauvegarde créé.
  Future<Result<String>> exportBackup();

  /// IMPORTANT — limite documentée : la connexion `drift` déjà ouverte au
  /// moment de l'appel ne voit pas le remplacement du fichier. L'appelant
  /// (couche présentation) doit informer l'utilisateur qu'un redémarrage
  /// de l'application est nécessaire après un import réussi.
  Future<Result<void>> importBackup(String sourcePath);

  Future<Result<List<String>>> listBackups();
}
