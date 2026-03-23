import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../data/database.dart';
import 'database_provider.dart';

final creditCardsProvider = StreamProvider<List<Account>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchCreditCards();
});

final creditCardTransactionsProvider = StreamProvider.family<List<Transaction>, int>((ref, cardId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.transactions)..where((t) => t.accountId.equals(cardId))..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();
});
