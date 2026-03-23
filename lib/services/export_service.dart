import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/database_provider.dart';

final exportServiceProvider = Provider((ref) => ExportService(ref));

class ExportService {
  final Ref _ref;

  ExportService(this._ref);

  Future<void> exportTransactionsToCsv() async {
    final db = _ref.read(databaseProvider);
    final txns = await db.getAllTransactions();
    final categories = await db.getAllCategories();
    final accounts = await db.getAllAccounts();

    final List<List<dynamic>> csvData = [
      ['Date', 'Amount (BDT)', 'Category', 'Account', 'Transaction Detail']
    ];

    for (final t in txns) {
      final cat = categories.firstWhere((c) => c.id == t.categoryId, orElse: () => categories.first);
      final acc = accounts.firstWhere((a) => a.id == t.accountId, orElse: () => accounts.first);
      final amountFormatted = (cat.type == 'Expense' ? '-' : '+') + t.amount.toStringAsFixed(2);
      
      csvData.add([
        t.date.toString().substring(0, 10),
        amountFormatted,
        cat.name,
        acc.name,
        t.note ?? '',
      ]);
    }

    final String csv = csvData.map((row) => row.map((e) => '"${e.toString().replaceAll('"', '""')}"').join(',')).join('\n');
    
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/Statement_Khorochpati.csv');
    await file.writeAsString(csv);
    
    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(file.path)], text: 'My Expense Statement');
  }
}
