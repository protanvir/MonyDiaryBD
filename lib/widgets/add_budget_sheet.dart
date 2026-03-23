import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../providers/database_provider.dart';
import '../providers/category_provider.dart';
import '../data/database.dart';

class AddBudgetSheet extends ConsumerStatefulWidget {
  const AddBudgetSheet({super.key});

  @override
  ConsumerState<AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends ConsumerState<AddBudgetSheet> {
  final _amountController = TextEditingController();
  int? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          Text('Set Monthly Budget', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 24),
          categoriesAsync.when(
            data: (categories) {
              final expenseCategories = categories.where((c) => c.type == 'Expense').toList();
              return DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'Expense Category', 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), 
                  filled: true, 
                  fillColor: theme.colorScheme.surfaceContainerHighest
                ),
                items: expenseCategories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, st) => Text('Error: $e'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: theme.textTheme.displaySmall?.copyWith(color: theme.colorScheme.primary),
            decoration: InputDecoration(
              prefixText: '৳ ',
              labelText: 'Budget Limit',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _submit(context, ref),
            child: const Text('Save Budget'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    if (_amountController.text.isEmpty || _selectedCategoryId == null) {
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
    final now = DateTime.now();
    await db.addBudget(BudgetsCompanion(
      categoryId: drift.Value(_selectedCategoryId!),
      amount: drift.Value(parsedAmount),
      month: drift.Value(now.month),
      year: drift.Value(now.year),
    ));

    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}
