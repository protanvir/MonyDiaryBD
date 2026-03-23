import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';
import 'database_provider.dart';

// Provides all transactions from the db
final transactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllTransactions();
});
