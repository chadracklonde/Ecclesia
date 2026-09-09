import '../../../../core/utils/result.dart';
import '../entities/subgroup.dart';
import '../repositories/subgroup_repository.dart';

class ListSubgroups {
  final SubgroupRepository repository;

  ListSubgroups(this.repository);

  Future<Result<List<Subgroup>>> call({required String churchId}) {
    return repository.getAllSubgroups(churchId: churchId);
  }
}
