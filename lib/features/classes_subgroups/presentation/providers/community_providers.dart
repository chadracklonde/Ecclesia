import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../members/presentation/providers/member_providers.dart';
import '../../data/datasources/local_church_class_datasource.dart';
import '../../data/datasources/local_subgroup_datasource.dart';
import '../../data/repositories/church_class_repository_impl.dart';
import '../../data/repositories/subgroup_repository_impl.dart';
import '../../domain/repositories/church_class_repository.dart';
import '../../domain/repositories/subgroup_repository.dart';
import '../../domain/usecases/assign_member_to_class.dart';
import '../../domain/usecases/assign_member_to_subgroup.dart';
import '../../domain/usecases/get_members_of_class.dart';
import '../../domain/usecases/get_members_of_subgroup.dart';
import '../../domain/usecases/list_classes.dart';
import '../../domain/usecases/list_subgroups.dart';

final churchClassRepositoryProvider = Provider<ChurchClassRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ChurchClassRepositoryImpl(LocalChurchClassDataSource(db));
});

final subgroupRepositoryProvider = Provider<SubgroupRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SubgroupRepositoryImpl(LocalSubgroupDataSource(db));
});

final listClassesUseCaseProvider = Provider<ListClasses>((ref) {
  return ListClasses(ref.watch(churchClassRepositoryProvider));
});

final listSubgroupsUseCaseProvider = Provider<ListSubgroups>((ref) {
  return ListSubgroups(ref.watch(subgroupRepositoryProvider));
});

final assignMemberToClassProvider = Provider<AssignMemberToClass>((ref) {
  return AssignMemberToClass(
    classRepository: ref.watch(churchClassRepositoryProvider),
    memberRepository: ref.watch(memberRepositoryProvider),
  );
});

final assignMemberToSubgroupProvider = Provider<AssignMemberToSubgroup>((ref) {
  return AssignMemberToSubgroup(
    subgroupRepository: ref.watch(subgroupRepositoryProvider),
    memberRepository: ref.watch(memberRepositoryProvider),
  );
});

final getMembersOfClassProvider = Provider<GetMembersOfClass>((ref) {
  return GetMembersOfClass(
    classRepository: ref.watch(churchClassRepositoryProvider),
    memberRepository: ref.watch(memberRepositoryProvider),
  );
});

final getMembersOfSubgroupProvider = Provider<GetMembersOfSubgroup>((ref) {
  return GetMembersOfSubgroup(
    subgroupRepository: ref.watch(subgroupRepositoryProvider),
    memberRepository: ref.watch(memberRepositoryProvider),
  );
});
