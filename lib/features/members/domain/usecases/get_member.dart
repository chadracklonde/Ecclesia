import '../../../../core/utils/result.dart';
import '../entities/member.dart';
import '../repositories/member_repository.dart';

class GetMember {
  final MemberRepository repository;

  GetMember(this.repository);

  Future<Result<Member>> call(String id) {
    return repository.getMemberById(id);
  }
}
