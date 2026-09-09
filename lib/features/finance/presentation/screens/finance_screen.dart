import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/financial_transaction.dart';
import '../providers/finance_list_providers.dart';
import '../providers/finance_providers.dart';
import 'depense_screen.dart';
import 'encaissement_screen.dart';

class FinanceScreen extends ConsumerWidget {
  final String churchId;

  const FinanceScreen({super.key, required this.churchId});

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

  String _formatAmount(int cents) {
    final value = cents / 100;
    return '${value.toStringAsFixed(2)} CDF';
  }

  Future<void> _cancelTransaction(
    BuildContext context,
    WidgetRef ref,
    FinancialTransaction transaction,
  ) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Annuler la transaction'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Motif (obligatoire)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Retour'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(reasonController.text),
            child: const Text('Confirmer l\'annulation'),
          ),
        ],
      ),
    );

    if (reason == null || reason.trim().isEmpty || !context.mounted) return;

    final cancelTransaction = ref.read(cancelTransactionProvider);
    final result = await cancelTransaction(
      transactionId: transaction.id,
      reason: reason.trim(),
    );

    if (!context.mounted) return;

    result.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        ref.invalidate(cashBalanceProvider(churchId));
        ref.invalidate(transactionsListProvider(churchId));
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(cashBalanceProvider(churchId));
    final transactionsAsync = ref.watch(transactionsListProvider(churchId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finances'),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            tooltip: 'Nouvelle dépense',
            onPressed: () async {
              final created = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => DepenseScreen(churchId: churchId)),
              );
              if (created == true) {
                ref.invalidate(cashBalanceProvider(churchId));
                ref.invalidate(transactionsListProvider(churchId));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Nouvel encaissement',
            onPressed: () async {
              final created = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => EncaissementScreen(churchId: churchId),
                ),
              );
              if (created == true) {
                ref.invalidate(cashBalanceProvider(churchId));
                ref.invalidate(transactionsListProvider(churchId));
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Solde caisse', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  balanceAsync.when(
                    data: (cents) => Text(
                      _formatAmount(cents),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    loading: () => const Text('…'),
                    error: (_, __) => const Text('—'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Erreur : $error')),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Center(
                    child: Text('Aucune transaction pour le moment.'),
                  );
                }
                return ListView.separated(
                  itemCount: transactions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final isExpense = tx.type == TransactionType.depense;
                    final label = tx.category != null
                        ? '${_typeLabel(tx.type)} — ${tx.category}'
                        : _typeLabel(tx.type);
                    return ListTile(
                      title: Text(label),
                      subtitle: Text(
                        tx.isCancelled
                            ? 'Annulée${tx.cancelledReason != null ? ' — ${tx.cancelledReason}' : ''}'
                            : '${tx.transactionDate.day}/${tx.transactionDate.month}/${tx.transactionDate.year}',
                        style: tx.isCancelled
                            ? TextStyle(color: Theme.of(context).colorScheme.error)
                            : null,
                      ),
                      trailing: Text(
                        '${isExpense ? '-' : '+'}${_formatAmount(tx.amountCents)}',
                        style: TextStyle(
                          color: tx.isCancelled
                              ? Theme.of(context).disabledColor
                              : (isExpense
                                  ? Theme.of(context).colorScheme.error
                                  : Colors.green),
                          decoration:
                              tx.isCancelled ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      onLongPress:
                          tx.isCancelled ? null : () => _cancelTransaction(context, ref, tx),
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
