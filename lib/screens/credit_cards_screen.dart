import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/credit_card_provider.dart';
import '../widgets/add_credit_card_sheet.dart';
import 'credit_card_detail_screen.dart';

class CreditCardsScreen extends ConsumerWidget {
  const CreditCardsScreen({super.key});

  IconData _networkIcon(String? network) {
    switch (network) {
      case 'VISA': return Icons.credit_card;
      case 'MasterCard': return Icons.credit_card;
      case 'AMEX': return Icons.credit_card;
      default: return Icons.credit_card;
    }
  }

  Color _networkColor(String? network, ThemeData theme) {
    switch (network) {
      case 'VISA': return const Color(0xFF1A1F71);
      case 'MasterCard': return const Color(0xFFEB001B);
      case 'AMEX': return const Color(0xFF006FCF);
      default: return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cardsAsync = ref.watch(creditCardsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Credit Cards',
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
        heroTag: 'cards_fab',
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            backgroundColor: theme.colorScheme.surface,
            builder: (_) => const AddCreditCardSheet(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Card'),
      ),
      body: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (cards) {
          if (cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.credit_card_off, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No credit cards yet', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text('Tap + to add your first card', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6))),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              final limit = card.initialBalance ?? 0.0;
              final outstanding = card.currentBalance ?? 0.0;
              final available = (limit - outstanding).clamp(0.0, double.infinity);
              final usagePercent = limit > 0 ? (outstanding / limit).clamp(0.0, 1.0) : 0.0;
              final netColor = _networkColor(card.cardNetwork, theme);

              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CreditCardDetailScreen(cardId: card.id)),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [netColor, netColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: netColor.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(_networkIcon(card.cardNetwork), color: Colors.white, size: 24),
                              const SizedBox(width: 8),
                              Text(card.cardNetwork ?? 'Card', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          Icon(Icons.chevron_right, color: Colors.white54),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(card.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                      const SizedBox(height: 16),
                      // Usage bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: usagePercent,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          color: usagePercent > 0.8 ? Colors.redAccent : Colors.white,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Outstanding', style: TextStyle(color: Colors.white60, fontSize: 11)),
                              Text('৳${outstanding.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Limit', style: TextStyle(color: Colors.white60, fontSize: 11)),
                              Text('৳${limit.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Available', style: TextStyle(color: Colors.white60, fontSize: 11)),
                              Text('৳${available.toStringAsFixed(0)}', style: TextStyle(color: usagePercent > 0.8 ? Colors.redAccent.shade100 : Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
