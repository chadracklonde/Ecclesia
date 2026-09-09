import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Hache les mots de passe avec SHA-256 + sel aléatoire.
///
/// LIMITE DOCUMENTÉE (décision actée le 09/09/2026, avec l'utilisateur) :
/// SHA-256 n'a pas de facteur de coût — il est rapide à calculer, donc
/// vulnérable au brute-force hors ligne si la base de données venait à
/// être extraite d'un appareil volé. bcrypt ou Argon2 seraient plus sûrs
/// mais nécessitent un paquet que je n'ai pas pu vérifier dans ce sandbox
/// (pas d'accès à pub.dev). Toute la logique de hachage est isolée dans
/// cette seule classe : passer à bcrypt/Argon2 plus tard ne touchera que
/// ce fichier, pas le reste du module Administration.
class PasswordHasher {
  static const _saltLength = 16;

  /// Génère un sel aléatoire encodé en base64.
  String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(_saltLength, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Hache `plainPassword` avec `salt`, retourne le hash encodé en hexadécimal.
  String hash(String plainPassword, String salt) {
    final bytes = utf8.encode('$salt:$plainPassword');
    return sha256.convert(bytes).toString();
  }

  bool verify(String plainPassword, String salt, String expectedHash) {
    return hash(plainPassword, salt) == expectedHash;
  }
}
