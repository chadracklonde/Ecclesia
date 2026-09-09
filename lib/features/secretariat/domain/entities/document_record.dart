import 'package:equatable/equatable.dart';

enum DocumentTemplateType {
  attestationMembre,
  certificatBapteme,
  lettreRecommandation,
}

/// Métadonnées du document — `filePath` reste nullable tant que la
/// génération PDF réelle n'est pas câblée (décision actée à l'Étape 8).
class DocumentRecord extends Equatable {
  final String id;
  final String churchId;
  final DocumentTemplateType templateType;
  final String title;
  final DateTime generatedDate;
  final String? relatedMemberId;
  final String? filePath;

  const DocumentRecord({
    required this.id,
    required this.churchId,
    required this.templateType,
    required this.title,
    required this.generatedDate,
    this.relatedMemberId,
    this.filePath,
  });

  @override
  List<Object?> get props =>
      [id, churchId, templateType, title, generatedDate, relatedMemberId, filePath];
}
