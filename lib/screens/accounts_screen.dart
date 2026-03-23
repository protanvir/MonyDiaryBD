import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/account_provider.dart';
import '../providers/database_provider.dart';
import '../data/database.dart';
import '../widgets/add_account_sheet.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'My Wallet',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: false,
      ),
      body: accountsAsync.when(
        data: (accounts) {
          final assets = accounts.where((a) => a.type != 'CreditCard').toList();
          final totalAssets = assets.fold(0.0, (sum, acc) => sum + (acc.initialBalance ?? 0));
          
          final creditCards = accounts.where((a) => a.type == 'CreditCard').toList();
          final totalLiability = creditCards.fold(0.0, (sum, acc) => sum + (acc.currentBalance ?? 0));

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildSummaryCard(context, totalAssets, totalLiability),
                ),
              ),
              if (assets.isNotEmpty) ...[
                _buildSectionHeader(context, 'CASH & BANK'),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildAccountTile(context, ref, assets[index]),
                    childCount: assets.length,
                  ),
                ),
              ],
              if (creditCards.isNotEmpty) ...[
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                _buildSectionHeader(context, 'CREDIT CARDS'),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildAccountTile(context, ref, creditCards[index]),
                    childCount: creditCards.length,
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAccountSheet(context, ref),
        label: const Text('Add Account', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, double assets, double debt) {
    final theme = Theme.of(context);
    final netWorth = assets - debt;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Text('Net Worth', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary.withOpacity(0.8))),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              '৳ ${netWorth.toStringAsFixed(0)}',
              style: theme.textTheme.displayMedium?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat(context, 'Assets', assets, theme.colorScheme.onPrimary),
              Container(width: 1, height: 30, color: theme.colorScheme.onPrimary.withOpacity(0.2)),
              _buildMiniStat(context, 'Liabilities', debt, theme.colorScheme.onPrimary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(BuildContext context, String label, double amount, Color color) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: color.withOpacity(0.7))),
        Text('৳${amount.toStringAsFixed(0)}', style: theme.textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 24, top: 24, bottom: 8),
        child: Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
    );
  }

  Widget _buildAccountTile(BuildContext context, WidgetRef ref, Account account) {
    final theme = Theme.of(context);
    
    final (icon, color) = _getAccountVisuals(account);
    final displayBalance = account.type == 'CreditCard' ? (account.currentBalance ?? 0.0) : (account.initialBalance ?? 0.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: InkWell(
        onTap: () => _showAccountSheet(context, ref, account: account),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(account.type, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('৳${displayBalance.toStringAsFixed(0)}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: account.type == 'CreditCard' ? theme.colorScheme.error : theme.colorScheme.primary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => _showAccountSheet(context, ref, account: account),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        onPressed: () => _confirmDelete(context, ref, account),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  (IconData, Color) _getAccountVisuals(Account account) {
    return switch (account.type) {
      'Cash' => (Icons.payments_outlined, Colors.teal),
      'Bank' => (Icons.account_balance_outlined, Colors.blue),
      'bKash' => (Icons.account_balance_wallet_outlined, const Color(0xFFE2136E)),
      'Nagad' => (Icons.account_balance_wallet_outlined, Colors.orange),
      'Rocket' => (Icons.account_balance_wallet_outlined, Colors.purple),
      'CreditCard' => (Icons.credit_card_outlined, Colors.indigo),
      _ => (Icons.wallet_outlined, Colors.grey),
    };
  }

  void _showAccountSheet(BuildContext context, WidgetRef ref, {Account? account}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AddAccountSheet(initialAccount: account),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Account account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: Text('Are you sure you want to delete "${account.name}"? This will also delete all associated transactions.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.read(databaseProvider).deleteAccountAndTransactions(account.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
