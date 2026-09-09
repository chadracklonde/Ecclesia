import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../members/domain/entities/member.dart';
import '../../../members/domain/repositories/member_repository.dart';
import '../entities/document_record.dart';
import '../repositories/document_record_repository.dart';

/// Enregistre les métadonnées d'un document officiel. La génération PDF
/// réelle n'est PAS câblée ici (décision actée : pas de paquet PDF
/// vérifiable dans ce sandbox) — `filePath` reste `null`. À câbler en
/// local avec un paquet comme `pdf`/`printing`, en remplissant ce champ
/// une fois le fichier réellement produit.
class GenerateDocument {
  final DocumentRecordRepository repository;
  final MemberRepository memberRepository;
  final Uuid uuid;

  GenerateDocument({
    required this.repository,
    required this.memberRepository,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  Future<Result<DocumentRecord>> call({
    required String churchId,
    required DocumentTemplateType templateType,
    required String relatedMemberId,
    String? customTitle,
  }) async {
    final memberResult = await memberRepository.getMemberById(relatedMemberId);
    if (memberResult is Error<Member>) {
      return Error(memberResult.failure);
    }
    final member = (memberResult as Success<Member>).value;

    if (member.churchId != churchId) {
      return const Error(
          ValidationFailure('Le membre doit appartenir à la même église'));
    }

    final title = (customTitle != null && customTitle.trim().isNotEmpty)
        ? customTitle.trim()
        : '${_templateLabel(templateType)} — ${member.firstName} ${member.lastName}';

    final record = DocumentRecord(
      id: uuid.v4(),
      churchId: churchId,
      templateType: templateType,
      title: title,
      generatedDate: DateTime.now(),
      relatedMemberId: relatedMemberId,
    );

    return repository.createDocumentRecord(record);
  }

  String _templateLabel(DocumentTemplateType type) {
    switch (type) {
      case DocumentTemplateType.attestationMembre:
        return 'Attestation de membre';
      case DocumentTemplateType.certificatBapteme:
        return 'Certificat de baptême';
      case DocumentTemplateType.lettreRecommandation:
        return 'Lettre de recommandation';
    }
  }
}
