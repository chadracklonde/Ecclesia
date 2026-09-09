import 'package:ecclesia/features/secretariat/data/pdf/document_pdf_generator.dart';
import 'package:ecclesia/features/secretariat/domain/entities/document_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('documentTitle', () {
    test('retourne le bon titre pour chaque type', () {
      expect(documentTitle(DocumentTemplateType.attestationMembre),
          'ATTESTATION DE MEMBRE');
      expect(documentTitle(DocumentTemplateType.certificatBapteme),
          'CERTIFICAT DE BAPTÊME');
      expect(documentTitle(DocumentTemplateType.lettreRecommandation),
          'LETTRE DE RECOMMANDATION');
    });
  });

  group('documentBody', () {
    test('inclut le nom et le matricule du membre', () {
      final body = documentBody(
        DocumentTemplateType.attestationMembre,
        'Jeanne Mukendi',
        'RTC-2026-0001',
        'RTC-MALI',
      );
      expect(body, contains('Jeanne Mukendi'));
      expect(body, contains('RTC-2026-0001'));
      expect(body, contains('RTC-MALI'));
    });
  });

  group('formatPdfDate', () {
    test('formate la date en jour/mois/année', () {
      expect(formatPdfDate(DateTime(2026, 9, 13)), '13/9/2026');
    });
  });
}
