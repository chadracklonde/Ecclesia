import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Encode le matricule (déjà unique et stable, Étape 0 décision #5)
/// plutôt qu'un identifiant technique séparé — évite de maintenir deux
/// identifiants différents pour la même fiche membre.
///
/// ⚠️ NON VÉRIFIÉ DANS CE SANDBOX : API de `qr_flutter` au meilleur de ma
/// connaissance du paquet, à confirmer via `flutter pub get` en local.
class MemberQrCode extends StatelessWidget {
  final String matricule;
  final double size;

  const MemberQrCode({super.key, required this.matricule, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: matricule,
      size: size,
      backgroundColor: Colors.white,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Colors.black,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Colors.black,
      ),
    );
  }
}
