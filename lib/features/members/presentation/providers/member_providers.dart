import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/datasources/local_matricule_counter_datasource.dart';
import '../../data/datasources/local_member_datasource.dart';
import '../../data/repositories/matricule_sequence_provider_impl.dart';
import '../../data/repositories/member_repository_impl.dart';
import '../../domain/repositories/matricule_sequence_provider.dart';
import '../../domain/repositories/member_repository.dart';
import '../../domain/usecases/change_member_status.dart';
import '../../domain/usecases/create_member.dart';
import '../../domain/usecases/get_member.dart';
import '../../domain/usecases/list_members.dart';

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return MemberRepositoryImpl(LocalMemberDataSource(db));
});

final matriculeSequenceProviderProvider = Provider<MatriculeSequenceProvider>(
  (ref) {
    final db = ref.watch(appDatabaseProvider);
    return MatriculeSequenceProviderImpl(LocalMatriculeCounterDataSource(db));
  },
);

final createMemberProvider = Provider<CreateMember>((ref) {
  return CreateMember(
    repository: ref.watch(memberRepositoryProvider),
    matriculeSequenceProvider: ref.watch(matriculeSequenceProviderProvider),
  );
});

final changeMemberStatusProvider = Provider<ChangeMemberStatus>((ref) {
  return ChangeMemberStatus(ref.watch(memberRepositoryProvider));
});

final listMembersUseCaseProvider = Provider<ListMembers>((ref) {
  return ListMembers(ref.watch(memberRepositoryProvider));
});

final getMemberProvider = Provider<GetMember>((ref) {
  return GetMember(ref.watch(memberRepositoryProvider));
});
