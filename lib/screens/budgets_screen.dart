import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/budget_provider.dart';
import '../widgets/add_budget_sheet.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final txnsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final budgetsAsync = ref.watch(budgetsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Budgets',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: theme.colorScheme.primaryContainer,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'budgets_fab',
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddBudgetSheet(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Budget'),
      ),
      body: SafeArea(
        child: categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
          data: (categories) {
            return budgetsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (budgets) {
                return txnsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Error: $e')),
                  data: (txns) {
                    final now = DateTime.now();
                    final thisMonthBudgets = budgets.where((b) => b.month == now.month && b.year == now.year).toList();
                    
                    final totalBudget = thisMonthBudgets.fold(0.0, (s, b) => s + b.amount);
                    double totalSpent = 0.0;
                    for (final t in txns) {
                      if (thisMonthBudgets.any((b) => b.categoryId == t.categoryId && t.date.month == now.month && t.date.year == now.year)) {
                        totalSpent += t.amount;
                      }
                    }
                    final totalPercent = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
                    final remaining = (totalBudget - totalSpent).clamp(0.0, double.infinity);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Compact Summary Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Monthly Budget', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary.withOpacity(0.8))),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${(totalPercent * 100).toStringAsFixed(0)}% used',
                                        style: theme.textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text('৳', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary.withOpacity(0.8))),
                                    const SizedBox(width: 4),
                                    Text(totalBudget.toStringAsFixed(0), style: theme.textTheme.headlineLarge?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w800)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: totalPercent,
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    color: Colors.white,
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Spent: ৳${totalSpent.toStringAsFixed(0)}', style: theme.textTheme.labelSmall?.copyWith(color: Colors.white.withOpacity(0.8))),
                                    Text('Remaining: ৳${remaining.toStringAsFixed(0)}', style: theme.textTheme.labelSmall?.copyWith(color: Colors.white.withOpacity(0.8))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          if (thisMonthBudgets.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 48),
                                child: Column(
                                  children: [
                                    Icon(Icons.pie_chart_outline, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3)),
                                    const SizedBox(height: 16),
                                    Text('No budgets set for this month', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                    const SizedBox(height: 4),
                                    Text('Tap + to create your first budget', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6))),
                                  ],
                                ),
                              ),
                            )
                          else ...[
                            Text('Category Budgets', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                            const SizedBox(height: 12),
                            ...thisMonthBudgets.map((budget) {
                              final cat = categories.where((c) => c.id == budget.categoryId).firstOrNull;
                              if (cat == null) return const SizedBox.shrink();

                              final limit = budget.amount;
                              final spent = txns.where((t) => t.categoryId == cat.id && t.date.month == now.month && t.date.year == now.year).fold(0.0, (s, t) => s + t.amount);
                              final percent = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;

                              Color barColor;
                              if (percent > 0.9) {
                                barColor = theme.colorScheme.error;
                              } else if (percent > 0.6) {
                                barColor = Colors.orange;
                              } else {
                                barColor = theme.colorScheme.primary;
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: barColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Icon(Icons.category, size: 18, color: barColor),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(cat.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        Text(
                                          '৳${spent.toStringAsFixed(0)} / ৳${limit.toStringAsFixed(0)}',
                                          style: theme.textTheme.labelMedium?.copyWith(
                                            color: percent > 0.9 ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: percent,
                                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                        color: barColor,
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                          const SizedBox(height: 80),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
