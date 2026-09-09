import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../members/domain/entities/member.dart';
import '../../domain/entities/church_class.dart';
import '../../domain/entities/subgroup.dart';
import 'community_providers.dart';

final classesListProvider =
    FutureProvider.family<List<ChurchClass>, String>((ref, churchId) async {
  final listClasses = ref.watch(listClassesUseCaseProvider);
  final result = await listClasses(churchId: churchId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (classes) => classes,
  );
});

final subgroupsListProvider =
    FutureProvider.family<List<Subgroup>, String>((ref, churchId) async {
  final listSubgroups = ref.watch(listSubgroupsUseCaseProvider);
  final result = await listSubgroups(churchId: churchId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (subgroups) => subgroups,
  );
});

final classMembersProvider =
    FutureProvider.family<List<Member>, String>((ref, classId) async {
  final getMembers = ref.watch(getMembersOfClassProvider);
  final result = await getMembers(classId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (members) => members,
  );
});

final subgroupMembersProvider =
    FutureProvider.family<List<Member>, String>((ref, subgroupId) async {
  final getMembers = ref.watch(getMembersOfSubgroupProvider);
  final result = await getMembers(subgroupId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (members) => members,
  );
});
