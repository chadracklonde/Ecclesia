import 'package:flutter/material.dart';

import '../../../../core/theme/status_colors.dart';
import '../../domain/entities/member.dart';

class StatusBadge extends StatelessWidget {
  final MemberStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final appStatus = status == MemberStatus.fullMember
        ? AppStatus.fullMember
        : AppStatus.probation;
    final colors = AppStatusPalette.of(appStatus, brightness);
    final label =
        status == MemberStatus.fullMember ? 'Pleine communion' : 'Probation';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.foreground,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
