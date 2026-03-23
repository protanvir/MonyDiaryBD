import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../providers/database_provider.dart';
import '../data/database.dart';

class AddCreditCardSheet extends ConsumerStatefulWidget {
  const AddCreditCardSheet({super.key});

  @override
  ConsumerState<AddCreditCardSheet> createState() => _AddCreditCardSheetState();
}

class _AddCreditCardSheetState extends ConsumerState<AddCreditCardSheet> {
  final _nameController = TextEditingController();
  final _limitController = TextEditingController();
  String _selectedNetwork = 'VISA';

  final List<String> _networks = ['VISA', 'MasterCard', 'AMEX'];

  Color _networkColor(String network) {
    switch (network) {
      case 'VISA': return const Color(0xFF1A1F71);
      case 'MasterCard': return const Color(0xFFEB001B);
      case 'AMEX': return const Color(0xFF006FCF);
      default: return Colors.grey;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        top: 8, left: 24, right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add Credit Card', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // Network selector
          Text('Card Network', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: _networks.map((net) {
              final isSelected = _selectedNetwork == net;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedNetwork = net),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? _networkColor(net) : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected ? null : Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                    ),
                    child: Center(
                      child: Text(
                        net,
                        style: TextStyle(
                          color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Card Name',
              hintText: 'e.g. My VISA Gold',
              prefixIcon: const Icon(Icons.credit_card),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _limitController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary),
            decoration: InputDecoration(
              prefixText: '৳ ',
              labelText: 'Credit Limit',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Add Card', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty || _limitController.text.isEmpty) return;

    double? limit;
    try {
      limit = double.parse(_limitController.text);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid limit')));
      return;
    }

    final db = ref.read(databaseProvider);
    await db.addAccount(AccountsCompanion(
      name: drift.Value(_nameController.text),
      type: const drift.Value('CreditCard'),
      initialBalance: drift.Value(limit),
      currentBalance: const drift.Value(0.0),
      cardNetwork: drift.Value(_selectedNetwork),
    ));

    if (mounted) Navigator.pop(context);
  }
}
