import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../domain/entities/document_record.dart';
import '../../domain/entities/inventory_item.dart';

String documentTemplateTypeToString(DocumentTemplateType type) {
  switch (type) {
    case DocumentTemplateType.attestationMembre:
      return 'attestation_membre';
    case DocumentTemplateType.certificatBapteme:
      return 'certificat_bapteme';
    case DocumentTemplateType.lettreRecommandation:
      return 'lettre_recommandation';
  }
}

DocumentTemplateType documentTemplateTypeFromString(String value) {
  switch (value) {
    case 'certificat_bapteme':
      return DocumentTemplateType.certificatBapteme;
    case 'lettre_recommandation':
      return DocumentTemplateType.lettreRecommandation;
    default:
      return DocumentTemplateType.attestationMembre;
  }
}

extension DocumentRecordRowMapper on DocumentRecordRow {
  DocumentRecord toDomain() {
    return DocumentRecord(
      id: id,
      churchId: churchId,
      templateType: documentTemplateTypeFromString(templateType),
      title: title,
      generatedDate: generatedDate,
      relatedMemberId: relatedMemberId,
      filePath: filePath,
    );
  }
}

extension DocumentRecordDomainMapper on DocumentRecord {
  DocumentRecordsCompanion toCompanion() {
    return DocumentRecordsCompanion.insert(
      id: id,
      churchId: churchId,
      templateType: documentTemplateTypeToString(templateType),
      title: title,
      generatedDate: Value(generatedDate),
      relatedMemberId: Value(relatedMemberId),
      filePath: Value(filePath),
    );
  }
}

extension InventoryItemRowMapper on InventoryItemRow {
  InventoryItem toDomain() {
    return InventoryItem(
      id: id,
      churchId: churchId,
      name: name,
      category: category,
      quantity: quantity,
      condition: condition,
      location: location,
      acquiredDate: acquiredDate,
    );
  }
}

extension InventoryItemDomainMapper on InventoryItem {
  InventoryItemsCompanion toInsertCompanion() {
    return InventoryItemsCompanion.insert(
      id: id,
      churchId: churchId,
      name: name,
      category: Value(category),
      quantity: Value(quantity),
      condition: Value(condition),
      location: Value(location),
      acquiredDate: Value(acquiredDate),
    );
  }

  InventoryItemsCompanion toUpdateCompanion() {
    return InventoryItemsCompanion(
      name: Value(name),
      category: Value(category),
      quantity: Value(quantity),
      condition: Value(condition),
      location: Value(location),
      acquiredDate: Value(acquiredDate),
      updatedAt: Value(DateTime.now()),
    );
  }
}
