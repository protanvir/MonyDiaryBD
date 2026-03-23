import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../data/database.dart';
import '../providers/credit_card_provider.dart';
import '../providers/category_provider.dart';
import '../providers/database_provider.dart';
import '../providers/account_provider.dart';
import '../widgets/pay_credit_card_sheet.dart';

class CreditCardDetailScreen extends ConsumerStatefulWidget {
  final int cardId;
  const CreditCardDetailScreen({super.key, required this.cardId});

  @override
  ConsumerState<CreditCardDetailScreen> createState() => _CreditCardDetailScreenState();
}

class _CreditCardDetailScreenState extends ConsumerState<CreditCardDetailScreen> {
  void _showRenameDialog(Account card) {
    final controller = TextEditingController(text: card.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Card'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Card Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await ref.read(databaseProvider).updateAccountName(card.id, controller.text);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Account card) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Card?'),
        content: const Text('This will permanently delete this card and all its transactions.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () async {
              await ref.read(databaseProvider).deleteAccountAndTransactions(card.id);
              if (ctx.mounted) {
                Navigator.pop(ctx); 
                Navigator.pop(context); 
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardsAsync = ref.watch(creditCardsProvider);
    final txnsAsync = ref.watch(creditCardTransactionsProvider(widget.cardId));
    final categoriesAsync = ref.watch(categoriesProvider);

    return cardsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (cards) {
        final card = cards.where((c) => c.id == widget.cardId).firstOrNull;
        if (card == null) return const Scaffold(body: Center(child: Text('Card not found')));

        final limit = card.initialBalance ?? 0.0;
        final outstanding = card.currentBalance ?? 0.0;
        final available = (limit - outstanding).clamp(0.0, double.infinity);
        final usagePercent = limit > 0 ? (outstanding / limit).clamp(0.0, 1.0) : 0.0;

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            title: Text(card.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _showRenameDialog(card),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: theme.colorScheme.error,
                onPressed: () => _showDeleteDialog(card),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statColumn('Credit Limit', '৳${limit.toStringAsFixed(0)}', theme),
                          _statColumn('Outstanding', '৳${outstanding.toStringAsFixed(0)}', theme, color: outstanding > 0 ? theme.colorScheme.error : null),
                          _statColumn('Available', '৳${available.toStringAsFixed(0)}', theme, color: theme.colorScheme.primary),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: usagePercent,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          color: usagePercent > 0.8 ? theme.colorScheme.error : theme.colorScheme.primary,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('${(usagePercent * 100).toStringAsFixed(1)}% of limit used', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddExpense(context, ref, theme, card),
                        icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                        label: const Text('Add Expense'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            showDragHandle: true,
                            backgroundColor: theme.colorScheme.surface,
                            builder: (_) => PayCreditCardSheet(creditCard: card),
                          );
                        },
                        icon: const Icon(Icons.payment, size: 18),
                        label: const Text('Pay Bill'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Text('Transaction History', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                const SizedBox(height: 12),

                categoriesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Text('Error: $e'),
                  data: (categories) {
                    return txnsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Text('Error: $e'),
                      data: (txns) {
                        if (txns.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text('No transactions yet', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                            ),
                          );
                        }

                        return Column(
                          children: txns.map((txn) {
                            final cat = categories.where((c) => c.id == txn.categoryId).firstOrNull;
                            final isBillPayment = cat?.name == 'Credit Card Payment';
                            
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: isBillPayment
                                      ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                                      : theme.colorScheme.errorContainer.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isBillPayment ? Icons.payment : Icons.shopping_bag_outlined,
                                  size: 20,
                                  color: isBillPayment ? theme.colorScheme.primary : theme.colorScheme.error,
                                ),
                              ),
                              title: Text((txn.note?.isEmpty ?? true) ? (cat?.name ?? 'Expense') : txn.note!, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(txn.date.toString().substring(0, 10), style: theme.textTheme.bodySmall),
                              trailing: Text(
                                isBillPayment ? '+৳${txn.amount.toStringAsFixed(0)}' : '-৳${txn.amount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: isBillPayment ? theme.colorScheme.primary : theme.colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statColumn(String label, String value, ThemeData theme, {Color? color}) {
    return Column(
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  void _showAddExpense(BuildContext context, WidgetRef ref, ThemeData theme, Account card) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    int? selectedCategoryId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: theme.colorScheme.surface,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final categoriesAsync = ref.watch(categoriesProvider);
            return Padding(
              padding: EdgeInsets.only(top: 8, left: 24, right: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Credit Card Expense', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  categoriesAsync.when(
                    data: (cats) {
                      final expenseCats = cats.where((c) => c.type == 'Expense').toList();
                      return DropdownButtonFormField<int>(
                        value: selectedCategoryId,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          filled: true, fillColor: theme.colorScheme.surfaceContainerHighest,
                        ),
                        items: expenseCats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                        onChanged: (val) => setSheetState(() => selectedCategoryId = val),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, st) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.error),
                    decoration: InputDecoration(
                      prefixText: '-৳ ',
                      labelText: 'Amount',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true, fillColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      labelText: 'Transaction Detail',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true, fillColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (amountController.text.isEmpty || selectedCategoryId == null) return;
                      double? amount;
                      try { amount = double.parse(amountController.text); } catch (_) { return; }

                      final db = ref.read(databaseProvider);
                      await db.addCreditCardExpense(TransactionsCompanion(
                        amount: drift.Value(amount),
                        date: drift.Value(DateTime.now()),
                        categoryId: drift.Value(selectedCategoryId!),
                        accountId: drift.Value(card.id),
                        note: drift.Value(noteController.text.isEmpty ? null : noteController.text),
                      ));

                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Record Expense', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
