import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../providers/database_provider.dart';
import '../providers/account_provider.dart';
import '../providers/category_provider.dart';
import '../data/database.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  int? _selectedAccountId;
  int? _selectedCategoryId;
  String _selectedType = 'Expense';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountsAsync = ref.watch(accountsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Padding(
      padding: EdgeInsets.only(
        top: 24, left: 24, right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New Transaction', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 24),
          
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Expense', label: Text('Expense')),
              ButtonSegment(value: 'Income', label: Text('Income')),
            ],
            selected: {_selectedType},
            onSelectionChanged: (newSelection) {
              setState(() {
                _selectedType = newSelection.first;
                _selectedCategoryId = null;
              });
            },
          ),
          const SizedBox(height: 24),
          
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: theme.textTheme.displaySmall?.copyWith(color: _selectedType == 'Expense' ? theme.colorScheme.error : theme.colorScheme.tertiary),
            decoration: InputDecoration(
              prefixText: _selectedType == 'Expense' ? '- ৳ ' : '+ ৳ ',
              labelText: 'Amount',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 16),
          accountsAsync.when(
            data: (accounts) => DropdownButtonFormField<int>(
              value: _selectedAccountId,
              decoration: InputDecoration(labelText: 'Account', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), filled: true, fillColor: theme.colorScheme.surfaceContainerHighest),
              items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
              onChanged: (val) => setState(() => _selectedAccountId = val),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, st) => Text('Error loading accounts: $e'),
          ),
          const SizedBox(height: 16),
          categoriesAsync.when(
            data: (categories) {
              final filteredCategories = categories.where((c) => c.type == _selectedType).toList();
              // Validate that the selected category ID is still in the filtered list
              if (_selectedCategoryId != null && !filteredCategories.any((c) => c.id == _selectedCategoryId)) {
                _selectedCategoryId = null;
              }
              
              return DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), filled: true, fillColor: theme.colorScheme.surfaceContainerHighest),
                items: filteredCategories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, st) => Text('Error: $e'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'Transaction Detail (Optional)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _submit(context, ref),
            child: const Text('Save Transaction'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    if (_amountController.text.isEmpty || _selectedAccountId == null || _selectedCategoryId == null) {
      return; 
    }
    
    double? parsedAmount;
    try {
      parsedAmount = double.parse(_amountController.text);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount.')));
      }
      return;
    }

    final db = ref.read(databaseProvider);
    await db.addTransaction(TransactionsCompanion(
      amount: Value(parsedAmount),
      date: Value(DateTime.now()),
      accountId: Value(_selectedAccountId!),
      categoryId: Value(_selectedCategoryId!),
      note: Value(_noteController.text.trim().isEmpty ? null : _noteController.text.trim()),
    ));

    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}
