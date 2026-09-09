import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../domain/entities/church_class.dart';
import '../../domain/entities/subgroup.dart';

extension ChurchClassRowMapper on ChurchClassRow {
  ChurchClass toDomain() {
    return ChurchClass(
      id: id,
      churchId: churchId,
      name: name,
      leaderMemberId: leaderMemberId,
      description: description,
    );
  }
}

extension ChurchClassDomainMapper on ChurchClass {
  ChurchClassesCompanion toCompanion() {
    return ChurchClassesCompanion.insert(
      id: id,
      churchId: churchId,
      name: name,
      leaderMemberId: Value(leaderMemberId),
      description: Value(description),
    );
  }
}

extension SubgroupRowMapper on SubgroupRow {
  Subgroup toDomain() {
    return Subgroup(
      id: id,
      churchId: churchId,
      name: name,
      type: type,
      leaderMemberId: leaderMemberId,
    );
  }
}

extension SubgroupDomainMapper on Subgroup {
  SubgroupsCompanion toCompanion() {
    return SubgroupsCompanion.insert(
      id: id,
      churchId: churchId,
      name: name,
      type: type,
      leaderMemberId: Value(leaderMemberId),
    );
  }
}
