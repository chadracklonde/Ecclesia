/// Configuration Supabase — À REMPLIR avant toute synchronisation réelle.
///
/// Décision actée à l'Étape 1 puis reconfirmée à l'Étape 10 : toutes les
/// plateformes (y compris Web) fonctionnent 100% hors-ligne d'abord, et
/// synchronisent via Supabase quand la connexion est disponible — jamais
/// l'inverse.
///
/// ⚠️ NON VÉRIFIÉ DANS CE SANDBOX : nécessite un vrai projet Supabase
/// (URL + clé anonyme), que je n'ai pas et ne peux pas créer ici.
class SupabaseConfig {
  static const String url = 'REMPLACER_PAR_URL_SUPABASE';
  static const String anonKey = 'REMPLACER_PAR_CLE_ANON_SUPABASE';

  static bool get isConfigured =>
      url != 'REMPLACER_PAR_URL_SUPABASE' &&
      anonKey != 'REMPLACER_PAR_CLE_ANON_SUPABASE';
}
