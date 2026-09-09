import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/member.dart';
import 'member_providers.dart';

/// `FutureProvider.family` plutôt qu'un `AsyncNotifier` : pas encore de
/// besoin de mutation locale d'état complexe pour cette liste — un
/// `ref.invalidate` après création/changement de statut suffit à ce stade.
/// À reconsidérer si des filtres/tri côté client s'ajoutent plus tard.
final membersListProvider =
    FutureProvider.family<List<Member>, String>((ref, churchId) async {
  final listMembers = ref.watch(listMembersUseCaseProvider);
  final result = await listMembers(churchId: churchId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (members) => members,
  );
});
