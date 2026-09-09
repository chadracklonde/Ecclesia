import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Génère une clé de chiffrement aléatoire au premier lancement et la
/// conserve dans le stockage sécurisé de la plateforme (Keychain iOS,
/// Keystore Android, Credential Manager Windows, Keychain macOS).
///
/// ⚠️ NON VÉRIFIÉ DANS CE SANDBOX : l'API de `flutter_secure_storage`
/// ci-dessous est correcte au meilleur de ma connaissance du paquet,
/// mais sa version exacte doit être confirmée localement
/// (`flutter pub get` + test réel sur chaque plateforme cible — le
/// comportement du stockage sécurisé diffère par OS).
class SecretKeyProvider {
  static const _storageKey = 'ecclesia_db_encryption_key';
  final FlutterSecureStorage _storage;

  SecretKeyProvider({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String> getOrCreateKey() async {
    final existing = await _storage.read(key: _storageKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final newKey = _generateKey();
    await _storage.write(key: _storageKey, value: newKey);
    return newKey;
  }

  String _generateKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
