import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/church_class.dart';
import '../../domain/repositories/church_class_repository.dart';
import '../datasources/local_church_class_datasource.dart';
import '../models/community_models.dart';

class ChurchClassRepositoryImpl implements ChurchClassRepository {
  final LocalChurchClassDataSource dataSource;

  ChurchClassRepositoryImpl(this.dataSource);

  @override
  Future<Result<ChurchClass>> createClass(ChurchClass churchClass) async {
    try {
      await dataSource.insertClass(churchClass.toCompanion());
      return Success(churchClass);
    } catch (e) {
      return Error(DatabaseFailure('Échec de la création de la classe : $e'));
    }
  }

  @override
  Future<Result<ChurchClass>> getClassById(String id) async {
    try {
      final row = await dataSource.getClassById(id);
      if (row == null) {
        return const Error(NotFoundFailure('Classe introuvable'));
      }
      return Success(row.toDomain());
    } catch (e) {
      return Error(DatabaseFailure('Échec de la lecture de la classe : $e'));
    }
  }

  @override
  Future<Result<List<ChurchClass>>> getAllClasses({
    required String churchId,
  }) async {
    try {
      final rows = await dataSource.getAllClasses(churchId);
      return Success(rows.map((r) => r.toDomain()).toList());
    } catch (e) {
      return Error(DatabaseFailure('Échec de la lecture des classes : $e'));
    }
  }

  @override
  Future<Result<void>> assignMemberToClass({
    required String memberId,
    required String classId,
  }) async {
    try {
      await dataSource.assignMember(memberId: memberId, classId: classId);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Échec du rattachement à la classe : $e'));
    }
  }

  @override
  Future<Result<void>> removeMemberFromClass({
    required String memberId,
    required String classId,
  }) async {
    try {
      await dataSource.removeMember(memberId: memberId, classId: classId);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Échec du retrait de la classe : $e'));
    }
  }

  @override
  Future<Result<List<String>>> getClassIdsForMember(String memberId) async {
    try {
      return Success(await dataSource.getClassIdsForMember(memberId));
    } catch (e) {
      return Error(DatabaseFailure('Échec de la lecture des classes du membre : $e'));
    }
  }

  @override
  Future<Result<List<String>>> getMemberIdsForClass(String classId) async {
    try {
      return Success(await dataSource.getMemberIdsForClass(classId));
    } catch (e) {
      return Error(DatabaseFailure('Échec de la lecture des membres de la classe : $e'));
    }
  }
}
