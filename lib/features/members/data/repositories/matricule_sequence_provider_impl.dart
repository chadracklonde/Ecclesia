import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/matricule_sequence_provider.dart';
import '../datasources/local_matricule_counter_datasource.dart';

class MatriculeSequenceProviderImpl implements MatriculeSequenceProvider {
  final LocalMatriculeCounterDataSource dataSource;

  MatriculeSequenceProviderImpl(this.dataSource);

  @override
  Future<Result<int>> nextSequence({
    required String churchId,
    required int year,
  }) async {
    try {
      final sequence =
          await dataSource.nextSequence(churchId: churchId, year: year);
      return Success(sequence);
    } catch (e) {
      return Error(
          DatabaseFailure('Échec de la génération du matricule : $e'));
    }
  }
}
