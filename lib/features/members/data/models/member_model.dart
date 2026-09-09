import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../domain/entities/member.dart';

extension MemberRowMapper on MemberRow {
  Member toDomain() {
    return Member(
      id: id,
      churchId: churchId,
      matricule: matricule,
      firstName: firstName,
      lastName: lastName,
      sex: sex == 'M' ? Sex.male : Sex.female,
      birthDate: birthDate,
      phone: phone,
      address: address,
      photoPath: photoPath,
      qrCodeValue: qrCodeValue,
      status:
          status == 'full_member' ? MemberStatus.fullMember : MemberStatus.probation,
      statusSince: statusSince,
      joinDate: joinDate,
      maritalStatus: maritalStatus,
      profession: profession,
    );
  }
}

extension MemberDomainMapper on Member {
  MembersCompanion toCompanion() {
    return MembersCompanion.insert(
      id: id,
      churchId: churchId,
      matricule: matricule,
      firstName: firstName,
      lastName: lastName,
      sex: sex == Sex.male ? 'M' : 'F',
      birthDate: Value(birthDate),
      phone: Value(phone),
      address: Value(address),
      photoPath: Value(photoPath),
      qrCodeValue: Value(qrCodeValue),
      status: status == MemberStatus.fullMember ? 'full_member' : 'probation',
      statusSince: statusSince,
      joinDate: joinDate,
      maritalStatus: Value(maritalStatus),
      profession: Value(profession),
    );
  }
}
