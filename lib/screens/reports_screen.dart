import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../data/database.dart';
import '../services/export_service.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final txnsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Editorial Finance',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: theme.colorScheme.primaryContainer,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Financial Insights',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Reports & Analytics.',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text('Last 6 Months', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        try {
                           ref.read(exportServiceProvider).exportTransactionsToCsv();
                        } catch (e) {
                          // ignore
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: theme.colorScheme.primary.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.download, size: 16, color: theme.colorScheme.onPrimary),
                            const SizedBox(width: 8),
                            Text('Export', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              txnsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
                data: (txns) {
                  return categoriesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text('Error: $e')),
                    data: (categories) {
                      // Calculate mapping
                      final spendingByCategory = <Category, double>{};
                      for (final cat in categories) {
                        if (cat.type == 'Expense') spendingByCategory[cat] = 0;
                      }
                      for (final t in txns) {
                        final cat = categories.firstWhere((c) => c.id == t.categoryId, orElse:() => categories.first);
                        if (cat.type == 'Expense') {
                          spendingByCategory[cat] = (spendingByCategory[cat] ?? 0) + t.amount;
                        }
                      }

                      final List<PieChartSectionData> sections = [];
                      final colors = [theme.colorScheme.primaryContainer, theme.colorScheme.tertiary, theme.colorScheme.secondary, Colors.orange, Colors.blue];
                      int colorIndex = 0;
                      double totalSpending = spendingByCategory.values.fold(0, (a, b) => a + b);

                      spendingByCategory.forEach((cat, amount) {
                        if (amount > 0) {
                          sections.add(PieChartSectionData(
                            color: colors[colorIndex % colors.length],
                            value: amount,
                            title: '',
                            radius: 16,
                          ));
                          colorIndex++;
                        }
                      });

                      if (sections.isEmpty) {
                        return const Center(child: Text('No expense data available.'));
                      }

                      return Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 24, offset: const Offset(0, 8)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Allocation', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 32),
                            SizedBox(
                              height: 200,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  PieChart(
                                    PieChartData(
                                      sectionsSpace: 4,
                                      centerSpaceRadius: 80,
                                      sections: sections,
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Top Spend', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1, color: theme.colorScheme.outline)),
                                      const SizedBox(height: 4),
                                      Text(
                                        spendingByCategory.entries.where((e) => e.value > 0).reduce((a, b) => a.value > b.value ? a : b).key.name,
                                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                            ...spendingByCategory.entries.where((e) => e.value > 0).map((e) {
                              final pColor = colors[categories.indexOf(e.key) % colors.length];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(width: 8, height: 8, decoration: BoxDecoration(color: pColor, shape: BoxShape.circle)),
                                        const SizedBox(width: 12),
                                        Text(e.key.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    Text('৳ ${e.value.toStringAsFixed(0)}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    }
                  );
                }
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
