import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/add_transaction_sheet.dart';
import '../services/backup_service.dart';
import 'profile_settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accountsAsync = ref.watch(accountsProvider);
    final transactionsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final userSettings = ref.watch(userSettingsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Money Diary',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: theme.colorScheme.primaryContainer,
              ),
            ),
            Text(
              'Your daily expense tracker',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primaryContainer.withOpacity(0.8),
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              ref.watch(themeModeProvider) == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: theme.colorScheme.primary,
            ),
            onPressed: () => ref.toggleTheme(),
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: theme.colorScheme.primary),
            onPressed: () {
              // Navigate to Profile Settings
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileSettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.cloud_upload_outlined, color: theme.colorScheme.primary),
            tooltip: 'Backup to Drive',
            onPressed: () async {
              try {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backing up...')));
                await ref.read(backupServiceProvider).backupDatabase();
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup successful!')));
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.cloud_download_outlined, color: theme.colorScheme.primary),
            tooltip: 'Restore from Drive',
            onPressed: () async {
              try {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restoring...')));
                await ref.read(backupServiceProvider).restoreDatabase();
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restore complete.')));
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning, ${userSettings.name}',
                style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                'Your Financial Sanctuary',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 32),
              
              // Net Balance Hero Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(color: theme.colorScheme.primaryContainer.withOpacity(0.2), blurRadius: 24, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Net Balance',
                      style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 8),
                    accountsAsync.when(
                      data: (accounts) {
                        final assets = accounts.where((a) => a.type != 'CreditCard').fold(0.0, (sum, acc) => sum + (acc.initialBalance ?? 0));
                        final outstanding = accounts.where((a) => a.type == 'CreditCard').fold(0.0, (sum, acc) => sum + (acc.currentBalance ?? 0));
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text('৳ ', style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8))),
                                Text(assets.toStringAsFixed(0), style: theme.textTheme.displayLarge?.copyWith(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.w800, letterSpacing: -2)),
                              ],
                            ),
                            if (outstanding > 0) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.credit_card, size: 14, color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Credit Card Outstanding: ',
                                      style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7)),
                                    ),
                                    Text(
                                      '৳${outstanding.toStringAsFixed(0)}',
                                      style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                      loading: () => const CircularProgressIndicator(color: Colors.white),
                      error: (e, st) => Text('Error', style: TextStyle(color: theme.colorScheme.error)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context, 
                          isScrollControlled: true, 
                          showDragHandle: true, 
                          backgroundColor: theme.colorScheme.surface, 
                          builder: (context) => const AddTransactionSheet(),
                        );
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Transaction', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('View All', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              categoriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
                data: (categories) {
                  return transactionsAsync.when(
                    data: (txns) {
                      if (txns.isEmpty) return const Text('No transactions yet.', style: TextStyle(color: Colors.grey));
                      
                      // Sort descending by date
                      final sortedTxns = List.of(txns)..sort((a, b) => b.date.compareTo(a.date));

                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: sortedTxns.take(5).map((txn) {
                            final cat = categories.where((c) => c.id == txn.categoryId).firstOrNull;
                            final isExpense = cat?.type == 'Expense';
                            final categoryName = cat?.name ?? 'Transaction';
                            return _buildTransactionTile(context, txn, isExpense, categoryName);
                          }).toList(),
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Text('Error: $e'),
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

  Widget _buildTransactionTile(BuildContext context, dynamic txn, bool isExpense, String categoryName) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        hoverColor: Colors.white,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isExpense ? theme.colorScheme.error.withOpacity(0.1) : theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            isExpense ? Icons.shopping_bag_outlined : Icons.account_balance,
            color: isExpense ? theme.colorScheme.error : theme.colorScheme.primary,
          ),
        ),
        title: Text(
          (txn.note?.isEmpty ?? true) ? categoryName : txn.note!,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
        ),
        subtitle: Text(
          txn.date.toString().substring(0, 10),
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
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

