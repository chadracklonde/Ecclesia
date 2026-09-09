import 'package:ecclesia/core/utils/result.dart';
import 'package:ecclesia/features/members/domain/entities/member.dart';
import 'package:ecclesia/features/members/domain/repositories/member_repository.dart';
import 'package:ecclesia/features/secretariat/domain/entities/document_record.dart';
import 'package:ecclesia/features/secretariat/domain/entities/inventory_item.dart';
import 'package:ecclesia/features/secretariat/domain/repositories/document_record_repository.dart';
import 'package:ecclesia/features/secretariat/domain/repositories/inventory_repository.dart';
import 'package:ecclesia/features/secretariat/domain/usecases/generate_document.dart';
import 'package:ecclesia/features/secretariat/domain/usecases/inventory_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDocumentRecordRepository extends Mock
    implements DocumentRecordRepository {}

class MockMemberRepository extends Mock implements MemberRepository {}

class MockInventoryRepository extends Mock implements InventoryRepository {}

void main() {
  group('GenerateDocument', () {
    late MockDocumentRecordRepository documentRepository;
    late MockMemberRepository memberRepository;
    late GenerateDocument generateDocument;

    final member = Member(
      id: 'member-1',
      churchId: 'church-1',
      matricule: 'RTC-2026-0001',
      firstName: 'Jeanne',
      lastName: 'Mukendi',
      sex: Sex.female,
      status: MemberStatus.fullMember,
      statusSince: DateTime(2026),
      joinDate: DateTime(2026),
    );

    setUpAll(() {
      registerFallbackValue(DocumentRecord(
        id: 'fallback',
        churchId: 'church-1',
        templateType: DocumentTemplateType.attestationMembre,
        title: 'fallback',
        generatedDate: DateTime(2026),
      ));
    });

    setUp(() {
      documentRepository = MockDocumentRecordRepository();
      memberRepository = MockMemberRepository();
      generateDocument = GenerateDocument(
        repository: documentRepository,
        memberRepository: memberRepository,
      );
    });

    test('génère un titre automatique à partir du type et du nom du membre',
        () async {
      when(() => memberRepository.getMemberById('member-1'))
          .thenAnswer((_) async => Success(member));
      when(() => documentRepository.createDocumentRecord(any()))
          .thenAnswer((invocation) async =>
              Success(invocation.positionalArguments.first as DocumentRecord));

      final result = await generateDocument(
        churchId: 'church-1',
        templateType: DocumentTemplateType.attestationMembre,
        relatedMemberId: 'member-1',
      );

      result.fold(
        (failure) => fail('Attendu un succès, reçu : ${failure.message}'),
        (doc) => expect(doc.title, 'Attestation de membre — Jeanne Mukendi'),
      );
    });

    test('rejette un membre d\'une autre église', () async {
      final otherChurchMember = Member(
        id: 'member-2',
        churchId: 'church-AUTRE',
        matricule: 'XXX-2026-0001',
        firstName: 'Paul',
        lastName: 'Ilunga',
        sex: Sex.male,
        status: MemberStatus.fullMember,
        statusSince: DateTime(2026),
        joinDate: DateTime(2026),
      );
      when(() => memberRepository.getMemberById('member-2'))
          .thenAnswer((_) async => Success(otherChurchMember));

      final result = await generateDocument(
        churchId: 'church-1',
        templateType: DocumentTemplateType.certificatBapteme,
        relatedMemberId: 'member-2',
      );

      expect(result, isA<Error<DocumentRecord>>());
      verifyNever(() => documentRepository.createDocumentRecord(any()));
    });
  });

  group('CreateInventoryItem', () {
    late MockInventoryRepository inventoryRepository;
    late CreateInventoryItem createInventoryItem;

    setUpAll(() {
      registerFallbackValue(const InventoryItem(
        id: 'fallback',
        churchId: 'church-1',
        name: 'fallback',
      ));
    });

    setUp(() {
      inventoryRepository = MockInventoryRepository();
      createInventoryItem =
          CreateInventoryItem(repository: inventoryRepository);
    });

    test('rejette un nom vide sans appeler le repository', () async {
      final result = await createInventoryItem(
        churchId: 'church-1',
        name: '   ',
      );

      expect(result, isA<Error<InventoryItem>>());
      verifyNever(() => inventoryRepository.createItem(any()));
    });

    test('rejette une quantité négative sans appeler le repository',
        () async {
      final result = await createInventoryItem(
        churchId: 'church-1',
        name: 'Chaises',
        quantity: -5,
      );

      expect(result, isA<Error<InventoryItem>>());
      verifyNever(() => inventoryRepository.createItem(any()));
    });
  });
}
