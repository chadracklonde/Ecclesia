import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/document_record.dart';

/// Génère les PDF des documents officiels — enfin câblé (TODO documenté
/// depuis l'Étape 8). Mise en page volontairement simple ; à enrichir
/// localement (logo, filigrane, signature scannée) si souhaité.
///
/// ⚠️ NON VÉRIFIÉ DANS CE SANDBOX : API du paquet `pdf` au meilleur de ma
/// connaissance, à confirmer via `flutter pub get` en local. La logique
/// de titre/texte (`_title`/`_body`) est en revanche une fonction pure
/// testable indépendamment du rendu PDF lui-même — voir les tests.
class DocumentPdfGenerator {
  Future<Uint8List> generate({
    required DocumentTemplateType templateType,
    required String churchName,
    required String memberFullName,
    required String memberMatricule,
    required DateTime issueDate,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(48),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                churchName,
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 32),
              pw.Center(
                child: pw.Text(
                  documentTitle(templateType),
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 32),
              pw.Text(
                documentBody(templateType, memberFullName, memberMatricule, churchName),
                style: const pw.TextStyle(fontSize: 12),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 48),
              pw.Text('Fait le ${formatPdfDate(issueDate)}'),
              pw.SizedBox(height: 48),
              pw.Text('Signature et cachet :'),
            ],
          ),
        ),
      ),
    );

    return doc.save();
  }
}

/// Fonctions pures, extraites pour rester testables sans dépendre du
/// rendu PDF réel (que ce sandbox ne peut pas exécuter).
String documentTitle(DocumentTemplateType type) {
  switch (type) {
    case DocumentTemplateType.attestationMembre:
      return 'ATTESTATION DE MEMBRE';
    case DocumentTemplateType.certificatBapteme:
      return 'CERTIFICAT DE BAPTÊME';
    case DocumentTemplateType.lettreRecommandation:
      return 'LETTRE DE RECOMMANDATION';
  }
}

String documentBody(
  DocumentTemplateType type,
  String memberFullName,
  String memberMatricule,
  String churchName,
) {
  switch (type) {
    case DocumentTemplateType.attestationMembre:
      return 'Nous soussignés attestons que $memberFullName '
          '(matricule $memberMatricule) est membre de $churchName.';
    case DocumentTemplateType.certificatBapteme:
      return 'Nous certifions que $memberFullName (matricule $memberMatricule) '
          'a été baptisé(e) au sein de $churchName.';
    case DocumentTemplateType.lettreRecommandation:
      return 'Nous recommandons $memberFullName (matricule $memberMatricule), '
          'membre de $churchName, reconnu(e) pour son engagement et son intégrité.';
  }
}

String formatPdfDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
