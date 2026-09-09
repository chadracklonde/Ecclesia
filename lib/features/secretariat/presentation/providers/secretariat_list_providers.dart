import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/document_record.dart';
import '../../domain/entities/inventory_item.dart';
import 'secretariat_providers.dart';

final documentsListProvider =
    FutureProvider.family<List<DocumentRecord>, String>((ref, churchId) async {
  final listDocuments = ref.watch(listDocumentsUseCaseProvider);
  final result = await listDocuments(churchId: churchId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (documents) => documents,
  );
});

final inventoryListProvider =
    FutureProvider.family<List<InventoryItem>, String>((ref, churchId) async {
  final listItems = ref.watch(listInventoryItemsUseCaseProvider);
  final result = await listItems(churchId: churchId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (items) => items,
  );
});
