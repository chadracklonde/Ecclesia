import 'package:ecclesia/core/errors/failures.dart';
import 'package:ecclesia/core/utils/result.dart';
import 'package:ecclesia/features/members/domain/entities/member.dart';
import 'package:ecclesia/features/members/domain/repositories/matricule_sequence_provider.dart';
import 'package:ecclesia/features/members/domain/repositories/member_repository.dart';
import 'package:ecclesia/features/members/domain/usecases/create_member.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMemberRepository extends Mock implements MemberRepository {}

class MockMatriculeSequenceProvider extends Mock
    implements MatriculeSequenceProvider {}

void main() {
  late MockMemberRepository repository;
  late MockMatriculeSequenceProvider sequenceProvider;
  late CreateMember createMember;

  setUpAll(() {
    registerFallbackValue(
      Member(
        id: 'fallback',
        churchId: 'church-1',
        matricule: 'RTC-2026-0000',
        firstName: 'X',
        lastName: 'Y',
        sex: Sex.male,
        status: MemberStatus.probation,
        statusSince: DateTime(2026),
        joinDate: DateTime(2026),
      ),
    );
  });

  setUp(() {
    repository = MockMemberRepository();
    sequenceProvider = MockMatriculeSequenceProvider();
    createMember = CreateMember(
      repository: repository,
      matriculeSequenceProvider: sequenceProvider,
    );
  });

  group('CreateMember', () {
    test('rejette un prénom vide sans appeler le repository', () async {
      final result = await createMember(
        churchId: 'church-1',
        churchCode: 'RTC',
        firstName: '  ',
        lastName: 'Mukendi',
        sex: Sex.female,
        initialStatus: MemberStatus.probation,
      );

      expect(result, isA<Error<Member>>());
      verifyNever(() => repository.createMember(any()));
    });

    test(
        'propage l\'échec du fournisseur de séquence sans appeler le repository',
        () async {
      when(() => sequenceProvider.nextSequence(
            churchId: any(named: 'churchId'),
            year: any(named: 'year'),
          )).thenAnswer(
        (_) async => const Error(DatabaseFailure('échec compteur')),
      );

      final result = await createMember(
        churchId: 'church-1',
        churchCode: 'RTC',
        firstName: 'Jeanne',
        lastName: 'Mukendi',
        sex: Sex.female,
        initialStatus: MemberStatus.probation,
      );

      expect(result, isA<Error<Member>>());
      verifyNever(() => repository.createMember(any()));
    });

    test('génère un matricule au format validé et délègue au repository',
        () async {
      when(() => sequenceProvider.nextSequence(
            churchId: any(named: 'churchId'),
            year: any(named: 'year'),
          )).thenAnswer((_) async => const Success(7));

      Member? capturedMember;
      when(() => repository.createMember(any())).thenAnswer((invocation) async {
        capturedMember =
            invocation.positionalArguments.first as Member;
        return Success(capturedMember!);
      });

      final result = await createMember(
        churchId: 'church-1',
        churchCode: 'rtc',
        firstName: 'Jeanne',
        lastName: 'Mukendi',
        sex: Sex.female,
        initialStatus: MemberStatus.probation,
      );

      expect(result, isA<Success<Member>>());
      expect(capturedMember?.matricule, 'RTC-${DateTime.now().year}-0007');
      expect(capturedMember?.status, MemberStatus.probation);
    });
  });
}
