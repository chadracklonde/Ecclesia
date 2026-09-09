import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../members/domain/entities/member.dart';
import '../../../members/presentation/providers/members_list_provider.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/find_member_by_matricule.dart';
import '../providers/attendance_list_providers.dart';
import '../providers/attendance_providers.dart';
import 'qr_scanner_screen.dart';

class AttendanceScreen extends ConsumerWidget {
  final String churchId;

  const AttendanceScreen({super.key, required this.churchId});

  Future<void> _scanQrCode(BuildContext context, WidgetRef ref) async {
    final scannedMatricule = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (scannedMatricule == null || !context.mounted) return;

    final allMembers = await ref.read(membersListProvider(churchId).future);
    final member = findMemberByMatricule(allMembers, scannedMatricule);

    if (!context.mounted) return;

    if (member == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aucun membre pour ce code : $scannedMatricule')),
      );
      return;
    }

    final recordPresence = ref.read(recordPresenceProvider);
    final result = await recordPresence(
      churchId: churchId,
      memberId: member.id,
      method: AttendanceMethod.qrScan,
    );

    if (!context.mounted) return;

    result.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        ref.invalidate(todayAttendanceProvider(churchId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${member.firstName} ${member.lastName} pointé(e).')),
        );
      },
    );
  }

  Future<void> _openPointerDialog(BuildContext context, WidgetRef ref) async {
    final allMembers = await ref.read(membersListProvider(churchId).future);
    final today = await ref.read(todayAttendanceProvider(churchId).future);
    final pointedIds = today.map((a) => a.memberId).toSet();
    final candidates =
        allMembers.where((m) => !pointedIds.contains(m.id)).toList();

    if (!context.mounted) return;

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tous les membres sont déjà pointés aujourd\'hui.')),
      );
      return;
    }

    final selected = await showDialog<Member>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Pointer un membre'),
        children: candidates
            .map((member) => SimpleDialogOption(
                  onPressed: () => Navigator.of(dialogContext).pop(member),
                  child: Text('${member.firstName} ${member.lastName}'),
                ))
            .toList(),
      ),
    );

    if (selected == null) return;

    final recordPresence = ref.read(recordPresenceProvider);
    final result = await recordPresence(
      churchId: churchId,
      memberId: selected.id,
      method: AttendanceMethod.manual,
    );

    if (!context.mounted) return;

    result.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => ref.invalidate(todayAttendanceProvider(churchId)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(todayAttendanceProvider(churchId));
    final membersAsync = ref.watch(membersListProvider(churchId));

    return Scaffold(
      appBar: AppBar(title: const Text('Présences')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openPointerDialog(context, ref),
        child: const Icon(Icons.check),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () => _scanQrCode(context, ref),
              icon: const Icon(Icons.qr_code_2),
              label: const Text('Scanner un QR code'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                attendanceAsync.when(
                  data: (attendance) => Text('${attendance.length} pointés'),
                  loading: () => const Text('…'),
                  error: (_, __) => const Text('—'),
                ),
                membersAsync.when(
                  data: (members) => Text('sur ${members.length} membres'),
                  loading: () => const Text('…'),
                  error: (_, __) => const Text('—'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: attendanceAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Erreur : $error')),
              data: (attendances) {
                if (attendances.isEmpty) {
                  return const Center(
                    child: Text('Aucun membre pointé pour le moment.'),
                  );
                }
                final membersById = {
                  for (final m in membersAsync.valueOrNull ?? <Member>[]) m.id: m,
                };
                return ListView.separated(
                  itemCount: attendances.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final attendance = attendances[index];
                    final member = membersById[attendance.memberId];
                    final label = member != null
                        ? '${member.firstName} ${member.lastName}'
                        : attendance.memberId;
                    return ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(label),
                      subtitle: Text(attendance.method == AttendanceMethod.qrScan
                          ? 'Scan QR'
                          : 'Pointage manuel'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
