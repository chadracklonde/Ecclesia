import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../members/domain/entities/member.dart';
import '../../../members/presentation/providers/members_list_provider.dart';
import '../../data/pdf/document_pdf_generator.dart';
import '../../domain/entities/document_record.dart';
import '../providers/secretariat_list_providers.dart';
import '../providers/secretariat_providers.dart';

class DocumentsListScreen extends ConsumerWidget {
  final String churchId;

  const DocumentsListScreen({super.key, required this.churchId});

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

  Future<void> _generate(BuildContext context, WidgetRef ref) async {
    final type = await showDialog<DocumentTemplateType>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Type de document'),
        children: DocumentTemplateType.values
            .map((t) => SimpleDialogOption(
                  onPressed: () => Navigator.of(dialogContext).pop(t),
                  child: Text(_templateLabel(t)),
                ))
            .toList(),
      ),
    );
    if (type == null || !context.mounted) return;

    final members = await ref.read(membersListProvider(churchId).future);
    if (!context.mounted) return;
    final member = await showDialog<Member>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Pour quel membre ?'),
        children: members
            .map((m) => SimpleDialogOption(
                  onPressed: () => Navigator.of(dialogContext).pop(m),
                  child: Text('${m.firstName} ${m.lastName}'),
                ))
            .toList(),
      ),
    );
    if (member == null || !context.mounted) return;

    final generateDocument = ref.read(generateDocumentProvider);
    final result = await generateDocument(
      churchId: churchId,
      templateType: type,
      relatedMemberId: member.id,
    );

    if (!context.mounted) return;

    result.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message))),
      (doc) async {
        ref.invalidate(documentsListProvider(churchId));

        // NOTE DE PORTÉE : nom d'église en dur ('RTC-MALI') faute de
        // ChurchRepository (même limite que churchCode dans le
        // formulaire membre, Étape 3.3 — pas encore résolue).
        final pdfBytes = await DocumentPdfGenerator().generate(
          templateType: doc.templateType,
          churchName: 'RTC-MALI',
          memberFullName: '${member.firstName} ${member.lastName}',
          memberMatricule: member.matricule,
          issueDate: doc.generatedDate,
        );

        if (!context.mounted) return;
        await Printing.layoutPdf(
          onLayout: (_) async => pdfBytes,
          name: doc.title,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(documentsListProvider(churchId));

    return Scaffold(
      appBar: AppBar(title: const Text('Documents')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _generate(context, ref),
        child: const Icon(Icons.note_add_outlined),
      ),
      body: documentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erreur : $error')),
        data: (documents) {
          if (documents.isEmpty) {
            return const Center(child: Text('Aucun document généré.'));
          }
          return ListView.separated(
            itemCount: documents.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = documents[index];
              return ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(doc.title),
                subtitle: Text(
                  '${_templateLabel(doc.templateType)} · ${doc.generatedDate.day}/${doc.generatedDate.month}/${doc.generatedDate.year}'
                  '${doc.filePath == null ? ' · PDF généré à la volée (non stocké sur disque)' : ''}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
