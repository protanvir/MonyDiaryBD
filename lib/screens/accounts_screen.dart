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
      body: SafeArea(
        child: accountsAsync.when(
          data: (accounts) {
            final totalBalance = accounts.fold(0.0, (sum, acc) => sum + (acc.initialBalance ?? 0));
            
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL LIQUIDITY',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '৳ ',
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: theme.colorScheme.primary.withOpacity(0.8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              totalBalance.toStringAsFixed(2),
                              style: theme.textTheme.displayMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  sliver: accounts.isEmpty
                      ? SliverToBoxAdapter(
                          child: const Center(child: Text('No accounts found.')),
                        )
                      : SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildAccountCard(context, ref, accounts[index]),
                            childCount: accounts.length,
                          ),
                        ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'accounts_fab',
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        elevation: 4,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            backgroundColor: theme.colorScheme.surface,
            builder: (context) => const AddAccountSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, WidgetRef ref, Account account) {
    final theme = Theme.of(context);
    
    // Determine styles based on Stitch design templates
    Color bgColor;
    Color iconColor;
    Color iconBgColor;
    Color textColor = theme.colorScheme.onSurface;
    IconData icon;
    String typeLabel = account.type.toUpperCase();

    if (account.type == 'bKash') {
      bgColor = theme.colorScheme.surfaceContainerLow;
      iconColor = const Color(0xFFE2136E); // bKash Pink
      iconBgColor = iconColor.withOpacity(0.1);
      icon = Icons.account_balance_wallet;
    } else if (account.type == 'Nagad') {
      bgColor = theme.colorScheme.surfaceContainerLow;
      iconColor = const Color(0xFFF57C00); // Nagad Orange
      iconBgColor = iconColor.withOpacity(0.1);
      icon = Icons.account_balance_wallet;
    } else if (account.type == 'Bank') {
      bgColor = theme.colorScheme.primaryContainer;
      textColor = theme.colorScheme.onPrimaryContainer;
      iconColor = theme.colorScheme.onPrimaryContainer;
      iconBgColor = theme.colorScheme.onPrimaryContainer.withOpacity(0.2);
      icon = Icons.account_balance;
    } else {
      // Cash
      bgColor = theme.colorScheme.surfaceContainerLow;
      iconColor = theme.colorScheme.onPrimaryFixed;
      iconBgColor = theme.colorScheme.primaryFixed;
      icon = Icons.payments;
    }

    return GestureDetector(
      onLongPress: () {
        final controller = TextEditingController(text: account.name);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Rename Account'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Account Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(
                onPressed: () async {
                  if (controller.text.isNotEmpty) {
                    await ref.read(databaseProvider).updateAccountName(account.id, controller.text);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor),
              ),
              if (account.type != 'Cash' && account.type != 'Bank')
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      typeLabel,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: iconColor, letterSpacing: 1),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '৳',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: account.type == 'Bank' ? theme.colorScheme.onPrimaryContainer.withOpacity(0.7) : theme.colorScheme.primary.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    account.initialBalance?.toStringAsFixed(0) ?? '0',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ));
  }
}

