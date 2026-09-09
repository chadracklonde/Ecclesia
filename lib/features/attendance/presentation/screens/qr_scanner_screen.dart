import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Scanne un QR code et retourne la chaîne décodée (le matricule du
/// membre, cf. `MemberQrCode`) via `Navigator.pop`.
///
/// ⚠️ NON VÉRIFIÉ DANS CE SANDBOX : API de `mobile_scanner` au meilleur
/// de ma connaissance du paquet — à confirmer via `flutter pub get` et
/// un test caméra réel en local (permissions caméra à accorder sur
/// l'appareil, non simulables ici). Sur desktop/web sans caméra, cet
/// écran échouera à l'ouverture — prévoir un repli vers le pointage
/// manuel (déjà en place dans `AttendanceScreen`).
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _handled = false;

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final value = barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;

    _handled = true;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner le QR code')),
      body: MobileScanner(onDetect: _onDetect),
    );
  }
}
