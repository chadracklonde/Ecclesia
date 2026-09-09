import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../domain/entities/preacher_assignment.dart';
import '../../domain/entities/service.dart';

String serviceTypeToString(ServiceType type) {
  switch (type) {
    case ServiceType.dominical:
      return 'dominical';
    case ServiceType.special:
      return 'special';
    case ServiceType.veillee:
      return 'veillee';
  }
}

ServiceType serviceTypeFromString(String value) {
  switch (value) {
    case 'special':
      return ServiceType.special;
    case 'veillee':
      return ServiceType.veillee;
    default:
      return ServiceType.dominical;
  }
}

String serviceStatusToString(ServiceStatus status) {
  switch (status) {
    case ServiceStatus.planned:
      return 'planifie';
    case ServiceStatus.held:
      return 'tenu';
    case ServiceStatus.cancelled:
      return 'annule';
  }
}

ServiceStatus serviceStatusFromString(String value) {
  switch (value) {
    case 'tenu':
      return ServiceStatus.held;
    case 'annule':
      return ServiceStatus.cancelled;
    default:
      return ServiceStatus.planned;
  }
}

extension ServiceRowMapper on ServiceRow {
  Service toDomain() {
    return Service(
      id: id,
      churchId: churchId,
      date: date,
      type: serviceTypeFromString(type),
      theme: theme,
      status: serviceStatusFromString(status),
    );
  }
}

extension ServiceDomainMapper on Service {
  ServicesCompanion toCompanion() {
    return ServicesCompanion.insert(
      id: id,
      churchId: churchId,
      date: date,
      type: serviceTypeToString(type),
      theme: Value(theme),
      status: Value(serviceStatusToString(status)),
    );
  }
}

String preacherRoleToString(PreacherRole role) =>
    role == PreacherRole.invite ? 'invite' : 'principal';

PreacherRole preacherRoleFromString(String value) =>
    value == 'invite' ? PreacherRole.invite : PreacherRole.principal;

extension PreacherAssignmentRowMapper on PreacherAssignmentRow {
  PreacherAssignment toDomain() {
    return PreacherAssignment(
      id: id,
      serviceId: serviceId,
      memberId: memberId,
      externalName: externalName,
      externalContact: externalContact,
      role: preacherRoleFromString(role),
    );
  }
}

extension PreacherAssignmentDomainMapper on PreacherAssignment {
  PreacherAssignmentsCompanion toCompanion() {
    return PreacherAssignmentsCompanion.insert(
      id: id,
      serviceId: serviceId,
      memberId: Value(memberId),
      externalName: Value(externalName),
      externalContact: Value(externalContact),
      role: Value(preacherRoleToString(role)),
    );
  }
}
