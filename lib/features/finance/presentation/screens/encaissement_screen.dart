import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../members/domain/entities/member.dart';
import '../../../members/presentation/providers/members_list_provider.dart';
import '../../domain/entities/financial_transaction.dart';
import '../providers/finance_list_providers.dart';
import '../providers/finance_providers.dart';

class EncaissementScreen extends ConsumerStatefulWidget {
  final String churchId;

  const EncaissementScreen({super.key, required this.churchId});

  @override
  ConsumerState<EncaissementScreen> createState() => _EncaissementScreenState();
}

class _EncaissementScreenState extends ConsumerState<EncaissementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  TransactionType _type = TransactionType.dime;
  Member? _selectedMember;
  bool _isSubmitting = false;
  String? _submitError;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int? _parseAmountCents(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    if (parsed == null) return null;
    return (parsed * 100).round();
  }

  Future<void> _pickMember() async {
    final members = await ref.read(membersListProvider(widget.churchId).future);
    if (!mounted) return;
    final selected = await showDialog<Member?>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Membre (optionnel)'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Aucun (offrande anonyme)'),
          ),
          ...members.map((m) => SimpleDialogOption(
                onPressed: () => Navigator.of(dialogContext).pop(m),
                child: Text('${m.firstName} ${m.lastName}'),
              )),
        ],
      ),
    );
    setState(() => _selectedMember = selected);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amountCents = _parseAmountCents(_amountController.text);
    if (amountCents == null || amountCents <= 0) {
      setState(() => _submitError = 'Montant invalide');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final recordIncome = ref.read(recordIncomeTransactionProvider);
    final result = await recordIncome(
      churchId: widget.churchId,
      type: _type,
      amountCents: amountCents,
      memberId: _selectedMember?.id,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    if (!mounted) return;

    // Les deux branches sont async (la réussite affiche un dialogue) : il
    // faut donc `await` ce fold pour que la navigation qui suit n'arrive
    // pas avant la fin du dialogue.
    await result.fold(
      (failure) async {
        setState(() {
          _isSubmitting = false;
          _submitError = failure.message;
        });
      },
      (data) async {
        ref.invalidate(cashBalanceProvider(widget.churchId));
        ref.invalidate(transactionsListProvider(widget.churchId));
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Encaissement enregistré'),
            content: Text('Reçu ${data.receipt.receiptNumber} généré.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        if (mounted) Navigator.of(context).pop(true);
      },
    );
  }

  String _typeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.dime:
        return 'Dîme';
      case TransactionType.offrande:
        return 'Offrande';
      case TransactionType.quete:
        return 'Quête';
      case TransactionType.depense:
        return 'Dépense';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvel encaissement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Wrap(
                spacing: 8,
                children: [TransactionType.dime, TransactionType.offrande, TransactionType.quete]
                    .map((type) => ChoiceChip(
                          label: Text(_typeLabel(type)),
                          selected: _type == type,
                          onSelected: (_) => setState(() => _type = type),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Montant (CDF)'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Le montant est obligatoire'
                    : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_selectedMember != null
                    ? '${_selectedMember!.firstName} ${_selectedMember!.lastName}'
                    : 'Aucun membre sélectionné'),
                trailing: TextButton(onPressed: _pickMember, child: const Text('Choisir')),
              ),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note (optionnel)'),
              ),
              const SizedBox(height: 20),
              if (_submitError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _submitError!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Encaisser et générer le reçu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
