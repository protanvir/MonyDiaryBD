import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../services/export_service.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All Types';

  final List<String> _filters = ['All Types', 'This Month', 'Income', 'Expense'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final txnsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: theme.colorScheme.primaryContainer,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: theme.colorScheme.primary),
            onPressed: () async {
              try {
                await ref.read(exportServiceProvider).exportTransactionsToCsv();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error exporting: $e')));
                }
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: Icon(Icons.search, color: theme.colorScheme.outline),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter),
                      child: _buildFilterChip(context, filter, isSelected),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: categoriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
                data: (categories) {
                  return txnsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text('Error: $e')),
                    data: (txns) {
                      final filteredTxns = txns.where((t) {
                        // 1. Search Query
                        if (_searchQuery.isNotEmpty) {
                          final note = (t.note ?? '').toLowerCase();
                          if (!note.contains(_searchQuery.toLowerCase())) {
                            return false;
                          }
                        }
                        
                        // 2. Filter Tabs
                        if (_selectedFilter == 'This Month') {
                          final now = DateTime.now();
                          if (t.date.month != now.month || t.date.year != now.year) {
                            return false;
                          }
                        } else if (_selectedFilter != 'All Types') {
                          // 'Income' or 'Expense'
                          final cat = categories.where((c) => c.id == t.categoryId).firstOrNull;
                          if (cat == null) return false;
                          if (_selectedFilter == 'Income' && cat.type != 'Income') return false;
                          if (_selectedFilter == 'Expense' && cat.type != 'Expense') return false;
                        }
                        return true;
                      }).toList();

                      // Sort by date descending
                      filteredTxns.sort((a, b) => b.date.compareTo(a.date));

                      if (filteredTxns.isEmpty) return const Center(child: Text('No transactions found.'));
                      
                      return ListView.builder(
                        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
                        itemCount: filteredTxns.length,
                        itemBuilder: (context, index) {
                          final txn = filteredTxns[index];
                          final cat = categories.where((c) => c.id == txn.categoryId).firstOrNull;
                          final isExpense = cat?.type == 'Expense';
                          final categoryName = cat?.name ?? 'Transaction';
                          return _buildTransactionTile(context, txn, isExpense, categoryName);
                        },
                      );
                    },
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, dynamic txn, bool isExpense, String categoryName) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isExpense ? const Color(0xFFE2136E).withOpacity(0.1) : theme.colorScheme.primaryFixed,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isExpense ? Icons.shopping_bag_outlined : Icons.account_balance,
                color: isExpense ? const Color(0xFFE2136E) : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (txn.note?.isEmpty ?? true) ? categoryName : txn.note!,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                  ),
                  Text(
                    txn.date.toString().substring(0, 10),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Text(
              '${isExpense ? "-" : "+"} ৳${txn.amount}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isExpense ? theme.colorScheme.tertiary : theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
