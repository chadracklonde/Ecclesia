import '../../../../core/utils/result.dart';
import '../entities/member.dart';
import '../repositories/member_repository.dart';

class ListMembers {
  final MemberRepository repository;

  ListMembers(this.repository);

  Future<Result<List<Member>>> call({required String churchId}) {
    return repository.getAllMembers(churchId: churchId);
  }
}
