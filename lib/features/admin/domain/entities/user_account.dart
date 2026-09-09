import 'package:equatable/equatable.dart';

/// Compte de connexion, distinct de `Member` (Étape 0). Le hash et le sel
/// du mot de passe restent volontairement hors de cette entité domaine —
/// c'est un détail de la couche data, jamais exposé aux usecases/UI au-delà
/// de l'authentification elle-même.
class UserAccount extends Equatable {
  final String id;
  final String churchId;
  final String username;
  final String? memberId;
  final String roleId;
  final bool isActive;

  const UserAccount({
    required this.id,
    required this.churchId,
    required this.username,
    this.memberId,
    required this.roleId,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, churchId, username, memberId, roleId, isActive];
}
