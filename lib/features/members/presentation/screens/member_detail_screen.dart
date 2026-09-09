import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/member.dart';
import '../providers/member_providers.dart';
import '../widgets/member_qr_code.dart';
import '../widgets/status_badge.dart';

class MemberDetailScreen extends ConsumerStatefulWidget {
  final String memberId;

  const MemberDetailScreen({super.key, required this.memberId});

  @override
  ConsumerState<MemberDetailScreen> createState() =>
      _MemberDetailScreenState();
}

class _MemberDetailScreenState extends ConsumerState<MemberDetailScreen> {
  Member? _member;
  bool _loading = true;
  bool _updatingStatus = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final getMember = ref.read(getMemberProvider);
    final result = await getMember(widget.memberId);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      (member) => setState(() {
        _loading = false;
        _member = member;
        _error = null;
      }),
    );
  }

  Future<void> _toggleStatus() async {
    final member = _member;
    if (member == null) return;
    final newStatus = member.status == MemberStatus.probation
        ? MemberStatus.fullMember
        : MemberStatus.probation;

    setState(() => _updatingStatus = true);
    final changeStatus = ref.read(changeMemberStatusProvider);
    final result =
        await changeStatus(memberId: member.id, newStatus: newStatus);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _updatingStatus = false;
        _error = failure.message;
      }),
      (updated) => setState(() {
        _updatingStatus = false;
        _member = updated;
        _error = null;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fiche membre')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _member == null
              ? Center(child: Text(_error ?? 'Membre introuvable'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_member!.firstName} ${_member!.lastName}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _member!.matricule,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      StatusBadge(status: _member!.status),
                      const SizedBox(height: 20),
                      Center(child: MemberQrCode(matricule: _member!.matricule)),
                      const SizedBox(height: 20),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      OutlinedButton(
                        onPressed: _updatingStatus ? null : _toggleStatus,
                        child: Text(
                          _member!.status == MemberStatus.probation
                              ? 'Passer en pleine communion'
                              : 'Repasser en probation',
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
