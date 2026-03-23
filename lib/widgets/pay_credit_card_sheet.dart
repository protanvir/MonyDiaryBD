import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';
import '../providers/database_provider.dart';
import '../providers/account_provider.dart';

class PayCreditCardSheet extends ConsumerStatefulWidget {
  final Account creditCard;
  const PayCreditCardSheet({super.key, required this.creditCard});

  @override
  ConsumerState<PayCreditCardSheet> createState() => _PayCreditCardSheetState();
}

class _PayCreditCardSheetState extends ConsumerState<PayCreditCardSheet> {
  final _amountController = TextEditingController();
  int? _sourceAccountId;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountsAsync = ref.watch(accountsProvider);
    final outstanding = widget.creditCard.currentBalance ?? 0.0;

    return Padding(
      padding: EdgeInsets.only(
        top: 8, left: 24, right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Pay Credit Card Bill', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Outstanding Balance:', style: theme.textTheme.bodyMedium),
                Text('৳${outstanding.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.error, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          accountsAsync.when(
            data: (accounts) {
              // Only show non-credit-card accounts as source
              final debitAccounts = accounts.where((a) => a.type != 'CreditCard').toList();
              return DropdownButtonFormField<int>(
                value: _sourceAccountId,
                decoration: InputDecoration(
                  labelText: 'Pay From',
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                ),
                items: debitAccounts.map((a) => DropdownMenuItem(
                  value: a.id,
                  child: Text('${a.name} (৳${(a.initialBalance ?? 0).toStringAsFixed(0)})'),
                )).toList(),
                onChanged: (val) => setState(() => _sourceAccountId = val),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, st) => Text('Error: $e'),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary),
            decoration: InputDecoration(
              prefixText: '৳ ',
              labelText: 'Payment Amount',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                _amountController.text = outstanding.toStringAsFixed(0);
              },
              child: const Text('Pay Full Balance'),
            ),
          ),
          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Make Payment', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_amountController.text.isEmpty || _sourceAccountId == null) return;

    double? amount;
    try {
      amount = double.parse(_amountController.text);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    final db = ref.read(databaseProvider);
    await db.payCreditCardBill(
      creditCardId: widget.creditCard.id,
      sourceAccountId: _sourceAccountId!,
      amount: amount,
      note: 'Credit card bill payment - ${widget.creditCard.name}',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment recorded!')));
      Navigator.pop(context);
    }
  }
}
