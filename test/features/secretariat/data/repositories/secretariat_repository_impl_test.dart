import 'package:drift/native.dart';
import 'package:ecclesia/core/database/database.dart';
import 'package:ecclesia/features/secretariat/data/datasources/local_document_record_datasource.dart';
import 'package:ecclesia/features/secretariat/data/datasources/local_inventory_datasource.dart';
import 'package:ecclesia/features/secretariat/data/repositories/document_record_repository_impl.dart';
import 'package:ecclesia/features/secretariat/data/repositories/inventory_repository_impl.dart';
import 'package:ecclesia/features/secretariat/domain/entities/document_record.dart';
import 'package:ecclesia/features/secretariat/domain/entities/inventory_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DocumentRecordRepositoryImpl documentRepository;
  late InventoryRepositoryImpl inventoryRepository;

  const churchId = 'church-1';

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.into(db.churches).insert(
        ChurchesCompanion.insert(id: churchId, code: 'RTC', name: 'RTC-MALI'));
    documentRepository =
        DocumentRecordRepositoryImpl(LocalDocumentRecordDataSource(db));
    inventoryRepository = InventoryRepositoryImpl(LocalInventoryDataSource(db));
  });

  tearDown(() async {
    await db.close();
  });

  group('DocumentRecordRepositoryImpl', () {
    test('createDocumentRecord puis getDocumentsForChurch retrouve le document',
        () async {
      await documentRepository.createDocumentRecord(DocumentRecord(
        id: 'doc-1',
        churchId: churchId,
        templateType: DocumentTemplateType.attestationMembre,
        title: 'Attestation de membre — Jeanne Mukendi',
        generatedDate: DateTime(2026, 9, 13),
        relatedMemberId: 'member-1',
      ));

      final result =
          await documentRepository.getDocumentsForChurch(churchId: churchId);
      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (documents) {
          expect(documents.length, 1);
          expect(documents.first.filePath, isNull); // PDF non câblé, attendu
        },
      );
    });
  });

  group('InventoryRepositoryImpl', () {
    test('createItem puis getItemsForChurch retrouve l\'article', () async {
      await inventoryRepository.createItem(const InventoryItem(
        id: 'item-1',
        churchId: churchId,
        name: 'Chaises plastiques',
        category: 'Mobilier',
        quantity: 150,
      ));

      final result = await inventoryRepository.getItemsForChurch(churchId: churchId);
      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (items) {
          expect(items.length, 1);
          expect(items.first.quantity, 150);
        },
      );
    });

    test('updateItem modifie la quantité existante', () async {
      await inventoryRepository.createItem(const InventoryItem(
        id: 'item-1',
        churchId: churchId,
        name: 'Chaises plastiques',
        quantity: 150,
      ));

      await inventoryRepository.updateItem(const InventoryItem(
        id: 'item-1',
        churchId: churchId,
        name: 'Chaises plastiques',
        quantity: 140, // 10 cassées
      ));

      final result = await inventoryRepository.getItemsForChurch(churchId: churchId);
      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (items) => expect(items.first.quantity, 140),
      );
    });

    test('deleteItem retire l\'article de la liste (suppression douce)',
        () async {
      await inventoryRepository.createItem(const InventoryItem(
        id: 'item-1',
        churchId: churchId,
        name: 'Chaises plastiques',
      ));
      await inventoryRepository.deleteItem('item-1');

      final result = await inventoryRepository.getItemsForChurch(churchId: churchId);
      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (items) => expect(items, isEmpty),
      );
    });
  });
}
