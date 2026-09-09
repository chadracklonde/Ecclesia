import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../members/presentation/providers/member_providers.dart';
import '../../data/datasources/local_document_record_datasource.dart';
import '../../data/datasources/local_inventory_datasource.dart';
import '../../data/repositories/document_record_repository_impl.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/repositories/document_record_repository.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/usecases/generate_document.dart';
import '../../domain/usecases/inventory_usecases.dart';
import '../../domain/usecases/list_documents.dart';

final documentRecordRepositoryProvider =
    Provider<DocumentRecordRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DocumentRecordRepositoryImpl(LocalDocumentRecordDataSource(db));
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return InventoryRepositoryImpl(LocalInventoryDataSource(db));
});

final generateDocumentProvider = Provider<GenerateDocument>((ref) {
  return GenerateDocument(
    repository: ref.watch(documentRecordRepositoryProvider),
    memberRepository: ref.watch(memberRepositoryProvider),
  );
});

final listDocumentsUseCaseProvider = Provider<ListDocuments>((ref) {
  return ListDocuments(ref.watch(documentRecordRepositoryProvider));
});

final createInventoryItemProvider = Provider<CreateInventoryItem>((ref) {
  return CreateInventoryItem(repository: ref.watch(inventoryRepositoryProvider));
});

final updateInventoryItemProvider = Provider<UpdateInventoryItem>((ref) {
  return UpdateInventoryItem(ref.watch(inventoryRepositoryProvider));
});

final listInventoryItemsUseCaseProvider = Provider<ListInventoryItems>((ref) {
  return ListInventoryItems(ref.watch(inventoryRepositoryProvider));
});

final deleteInventoryItemProvider = Provider<DeleteInventoryItem>((ref) {
  return DeleteInventoryItem(ref.watch(inventoryRepositoryProvider));
});
