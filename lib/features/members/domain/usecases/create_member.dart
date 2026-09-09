import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/member.dart';
import '../repositories/matricule_sequence_provider.dart';
import '../repositories/member_repository.dart';
import 'generate_matricule.dart';

/// Orchestre la création d'un membre : validation, génération du
/// matricule via un compteur atomique, puis persistance.
///
/// NOTE DE PORTÉE : `churchCode` est passé par l'appelant plutôt que
/// résolu via un `ChurchRepository` — ce dernier n'existe pas encore
/// (prévu avec l'Étape 9, Administration, ou dès que le multi-église
/// est activé). L'appelant (couche présentation) connaît déjà l'église
/// courante dans le contexte applicatif actuel (mono-église).
class CreateMember {
  final MemberRepository repository;
  final MatriculeSequenceProvider matriculeSequenceProvider;
  final GenerateMatricule generateMatricule;
  final Uuid uuid;

  CreateMember({
    required this.repository,
    required this.matriculeSequenceProvider,
    GenerateMatricule? generateMatricule,
    Uuid? uuid,
  })  : generateMatricule = generateMatricule ?? GenerateMatricule(),
        uuid = uuid ?? const Uuid();

  Future<Result<Member>> call({
    required String churchId,
    required String churchCode,
    required String firstName,
    required String lastName,
    required Sex sex,
    DateTime? birthDate,
    String? phone,
    String? address,
    String? maritalStatus,
    String? profession,
    required MemberStatus initialStatus,
  }) async {
    if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
      return const Error(
          ValidationFailure('Le prénom et le nom sont obligatoires'));
    }

    final now = DateTime.now();
    final sequenceResult = await matriculeSequenceProvider.nextSequence(
      churchId: churchId,
      year: now.year,
    );

    if (sequenceResult is Error<int>) {
      return Error(sequenceResult.failure);
    }
    final sequence = (sequenceResult as Success<int>).value;

    final matricule = generateMatricule(
      churchCode: churchCode,
      year: now.year,
      sequence: sequence,
    );

    final member = Member(
      id: uuid.v4(),
      churchId: churchId,
      matricule: matricule,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      sex: sex,
      birthDate: birthDate,
      phone: phone,
      address: address,
      maritalStatus: maritalStatus,
      profession: profession,
      status: initialStatus,
      statusSince: now,
      joinDate: now,
    );

    return repository.createMember(member);
  }
}
