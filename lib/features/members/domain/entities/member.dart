import 'package:equatable/equatable.dart';

/// Statut d'un membre — cf. Étape 0, distinction validée.
enum MemberStatus { probation, fullMember }

enum Sex { male, female }

/// Entité domaine complète du Membre, alignée sur le dictionnaire
/// d'entités validé à l'Étape 0.
///
/// NOTE D'AUDIT (Étape 3.1) : la version produite à l'Étape 1 (PoC) était
/// volontairement réduite à un sous-ensemble de champs pour prouver le
/// câblage drift/test. Cette version la remplace intégralement — c'est
/// la même classe, complétée, pas une nouvelle entité parallèle.
class Member extends Equatable {
  final String id;
  final String churchId;
  final String matricule;
  final String firstName;
  final String lastName;
  final Sex sex;
  final DateTime? birthDate;
  final String? phone;
  final String? address;
  final String? photoPath;
  final String? qrCodeValue;
  final MemberStatus status;
  final DateTime statusSince;
  final DateTime joinDate;
  final String? maritalStatus;
  final String? profession;

  const Member({
    required this.id,
    required this.churchId,
    required this.matricule,
    required this.firstName,
    required this.lastName,
    required this.sex,
    this.birthDate,
    this.phone,
    this.address,
    this.photoPath,
    this.qrCodeValue,
    required this.status,
    required this.statusSince,
    required this.joinDate,
    this.maritalStatus,
    this.profession,
  });

  Member copyWith({
    MemberStatus? status,
    DateTime? statusSince,
  }) {
    return Member(
      id: id,
      churchId: churchId,
      matricule: matricule,
      firstName: firstName,
      lastName: lastName,
      sex: sex,
      birthDate: birthDate,
      phone: phone,
      address: address,
      photoPath: photoPath,
      qrCodeValue: qrCodeValue,
      status: status ?? this.status,
      statusSince: statusSince ?? this.statusSince,
      joinDate: joinDate,
      maritalStatus: maritalStatus,
      profession: profession,
    );
  }

  @override
  List<Object?> get props => [
        id,
        churchId,
        matricule,
        firstName,
        lastName,
        sex,
        birthDate,
        phone,
        address,
        photoPath,
        qrCodeValue,
        status,
        statusSince,
        joinDate,
        maritalStatus,
        profession,
      ];
}
