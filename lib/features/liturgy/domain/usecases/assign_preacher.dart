import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../members/domain/entities/member.dart';
import '../../../members/domain/repositories/member_repository.dart';
import '../entities/preacher_assignment.dart';
import '../entities/service.dart';
import '../repositories/preacher_assignment_repository.dart';
import '../repositories/service_repository.dart';

class AssignPreacher {
  final PreacherAssignmentRepository assignmentRepository;
  final ServiceRepository serviceRepository;
  final MemberRepository memberRepository;
  final Uuid uuid;

  AssignPreacher({
    required this.assignmentRepository,
    required this.serviceRepository,
    required this.memberRepository,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  Future<Result<PreacherAssignment>> call({
    required String serviceId,
    String? memberId,
    String? externalName,
    String? externalContact,
    PreacherRole role = PreacherRole.principal,
  }) async {
    if (memberId == null &&
        (externalName == null || externalName.trim().isEmpty)) {
      return const Error(ValidationFailure(
          'Il faut soit un membre, soit un nom de prédicateur externe'));
    }

    final serviceResult = await serviceRepository.getServiceById(serviceId);
    if (serviceResult is Error<Service>) {
      return Error(serviceResult.failure);
    }
    final service = (serviceResult as Success<Service>).value;

    if (memberId != null) {
      final memberResult = await memberRepository.getMemberById(memberId);
      if (memberResult is Error<Member>) {
        return Error(memberResult.failure);
      }
      final member = (memberResult as Success<Member>).value;
      if (member.churchId != service.churchId) {
        return const Error(ValidationFailure(
            'Le membre et le culte doivent appartenir à la même église'));
      }

      final conflictResult = await _hasSchedulingConflict(
        churchId: service.churchId,
        date: service.date,
        excludingServiceId: serviceId,
        memberId: memberId,
      );
      if (conflictResult is Error<bool>) {
        return Error(conflictResult.failure);
      }
      if ((conflictResult as Success<bool>).value) {
        return const Error(ValidationFailure(
            'Ce membre est déjà prédicateur d\'un autre culte le même jour'));
      }
    }

    final assignment = PreacherAssignment(
      id: uuid.v4(),
      serviceId: serviceId,
      memberId: memberId,
      externalName: externalName?.trim(),
      externalContact: externalContact,
      role: role,
    );

    return assignmentRepository.assignPreacher(assignment);
  }

  /// Détecte si `memberId` est déjà prédicateur d'un autre culte le même
  /// jour calendaire — critère de validation explicite de l'Étape 7
  /// ("pas de conflit de planning non détecté").
  Future<Result<bool>> _hasSchedulingConflict({
    required String churchId,
    required DateTime date,
    required String excludingServiceId,
    required String memberId,
  }) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final servicesResult = await serviceRepository.getServicesForChurch(
      churchId: churchId,
      from: dayStart,
      to: dayEnd,
    );
    if (servicesResult is Error<List<Service>>) {
      return Error(servicesResult.failure);
    }
    final servicesSameDay = (servicesResult as Success<List<Service>>)
        .value
        .where((s) => s.id != excludingServiceId);

    for (final other in servicesSameDay) {
      final assignmentsResult =
          await assignmentRepository.getAssignmentsForService(other.id);
      if (assignmentsResult is Error<List<PreacherAssignment>>) {
        return Error(assignmentsResult.failure);
      }
      final hasConflict = (assignmentsResult as Success<List<PreacherAssignment>>)
          .value
          .any((a) => a.memberId == memberId);
      if (hasConflict) {
        return const Success(true);
      }
    }
    return const Success(false);
  }
}
