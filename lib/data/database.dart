import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // "bKash", "Nagad", "Bank", "Cash", "CreditCard"
  RealColumn get initialBalance => real().withDefault(const Constant(0.0))(); // For CreditCard: credit limit
  RealColumn get currentBalance => real().withDefault(const Constant(0.0))(); // For CreditCard: outstanding balance owed
  TextColumn get colorHex => text().nullable()();
  TextColumn get cardNetwork => text().nullable()(); // "VISA", "MasterCard", "AMEX" - only for CreditCard
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // "Income", "Expense"
  TextColumn get iconName => text().nullable()();
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  IntColumn get accountId => integer().references(Accounts, #id)();
  TextColumn get note => text().nullable()();
}

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  RealColumn get amount => real()();
  IntColumn get month => integer()();
  IntColumn get year => integer()();
}

@DriftDatabase(tables: [Accounts, Categories, Transactions, Budgets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(accounts, accounts.currentBalance);
        await m.addColumn(accounts, accounts.cardNetwork);
      }
    },
  );

  // ── Accounts ──────────────────────────────────────────
  Future<List<Account>> getAllAccounts() => select(accounts).get();
  Stream<List<Account>> watchAllAccounts() => select(accounts).watch();
  Future<int> addAccount(AccountsCompanion entry) => into(accounts).insert(entry);

  // ── Credit Cards ──────────────────────────────────────
  Stream<List<Account>> watchCreditCards() =>
    (select(accounts)..where((a) => a.type.equals('CreditCard'))).watch();

  Future<List<Account>> getCreditCards() =>
    (select(accounts)..where((a) => a.type.equals('CreditCard'))).get();

  /// Add a credit card expense: increases outstanding balance on the card
  Future<int> addCreditCardExpense(TransactionsCompanion entry) async {
    return transaction(() async {
      final card = await (select(accounts)..where((a) => a.id.equals(entry.accountId.value))).getSingle();
      final amount = entry.amount.value;

      // Increase outstanding balance
      final newOutstanding = (card.currentBalance ?? 0.0) + amount;
      await (update(accounts)..where((a) => a.id.equals(card.id)))
          .write(AccountsCompanion(currentBalance: Value(newOutstanding)));

      return into(transactions).insert(entry);
    });
  }

  /// Pay credit card bill: deducts from source account, reduces card outstanding, records transaction
  Future<void> payCreditCardBill({
    required int creditCardId,
    required int sourceAccountId,
    required double amount,
    required String note,
  }) async {
    return transaction(() async {
      final card = await (select(accounts)..where((a) => a.id.equals(creditCardId))).getSingle();
      final source = await (select(accounts)..where((a) => a.id.equals(sourceAccountId))).getSingle();

      // Reduce outstanding on card
      final newOutstanding = ((card.currentBalance ?? 0.0) - amount).clamp(0.0, double.infinity);
      await (update(accounts)..where((a) => a.id.equals(card.id)))
          .write(AccountsCompanion(currentBalance: Value(newOutstanding)));

      // Deduct from source account
      final newSourceBal = (source.initialBalance ?? 0.0) - amount;
      await (update(accounts)..where((a) => a.id.equals(source.id)))
          .write(AccountsCompanion(initialBalance: Value(newSourceBal)));

      // Find or use a generic category for the bill payment
      final allCats = await select(categories).get();
      var billCat = allCats.where((c) => c.name == 'Credit Card Payment').firstOrNull;
      if (billCat == null) {
        final catId = await into(categories).insert(CategoriesCompanion(
          name: const Value('Credit Card Payment'),
          type: const Value('Expense'),
        ));
        billCat = await (select(categories)..where((c) => c.id.equals(catId))).getSingle();
      }

      // Record a transaction on the credit card account
      await into(transactions).insert(TransactionsCompanion(
        amount: Value(amount),
        date: Value(DateTime.now()),
        categoryId: Value(billCat.id),
        accountId: Value(creditCardId),
        note: Value(note),
      ));
    });
  }

  Future<void> updateAccountName(int accountId, String newName) async {
    await (update(accounts)..where((a) => a.id.equals(accountId)))
        .write(AccountsCompanion(name: Value(newName)));
  }

  Future<void> deleteAccountAndTransactions(int accountId) async {
    return transaction(() async {
      await (delete(transactions)..where((t) => t.accountId.equals(accountId))).go();
      await (delete(accounts)..where((a) => a.id.equals(accountId))).go();
    });
  }

  // ── Categories ────────────────────────────────────────
  Future<List<Category>> getAllCategories() => select(categories).get();
  Stream<List<Category>> watchAllCategories() => select(categories).watch();
  Future<int> addCategory(CategoriesCompanion entry) => into(categories).insert(entry);

  // ── Transactions ──────────────────────────────────────
  Future<List<Transaction>> getAllTransactions() => select(transactions).get();
  Stream<List<Transaction>> watchAllTransactions() => select(transactions).watch();

  Future<int> addTransaction(TransactionsCompanion entry) async {
    return transaction(() async {
      final cat = await (select(categories)..where((c) => c.id.equals(entry.categoryId.value))).getSingle();
      final acc = await (select(accounts)..where((a) => a.id.equals(entry.accountId.value))).getSingle();
      
      final amount = entry.amount.value;
      final isExpense = cat.type == 'Expense';
      
      if (acc.type == 'CreditCard') {
        final currentOut = acc.currentBalance ?? 0.0;
        final newOut = isExpense ? (currentOut + amount) : (currentOut - amount).clamp(0.0, double.infinity);
        await (update(accounts)..where((a) => a.id.equals(acc.id))).write(AccountsCompanion(currentBalance: Value(newOut)));
      } else {
        final currentBal = acc.initialBalance ?? 0.0;
        final newBal = isExpense ? (currentBal - amount) : (currentBal + amount);
        await (update(accounts)..where((a) => a.id.equals(acc.id))).write(AccountsCompanion(initialBalance: Value(newBal)));
      }
      
      return into(transactions).insert(entry);
    });
  }

  // ── Budgets ───────────────────────────────────────────
  Future<List<Budget>> getAllBudgets() => select(budgets).get();
  Stream<List<Budget>> watchAllBudgets() => select(budgets).watch();

  Future<int> addBudget(BudgetsCompanion entry) async {
    final existing = await (select(budgets)
      ..where((b) => b.categoryId.equals(entry.categoryId.value) & b.month.equals(entry.month.value) & b.year.equals(entry.year.value))
    ).get();
    for (final old in existing) {
      await (delete(budgets)..where((b) => b.id.equals(old.id))).go();
    }
    return into(budgets).insert(entry);
  }

  // ── Seed ──────────────────────────────────────────────
  Future<void> seedDefaultData() async {
    final hasAccounts = await select(accounts).get().then((v) => v.isNotEmpty);
    if (!hasAccounts) {
      await into(accounts).insert(AccountsCompanion(name: const Value('Cash'), type: const Value('Cash'), initialBalance: const Value(0)));
      await into(accounts).insert(AccountsCompanion(name: const Value('bKash'), type: const Value('bKash'), initialBalance: const Value(0)));
    }

    final existingCategories = await select(categories).get();
    final existingNames = existingCategories.map((c) => c.name).toSet();

    final defaultCategories = [
      ('Salary', 'Income'), ('Freelance', 'Income'), ('Business', 'Income'), 
      ('Rental', 'Income'), ('Gift', 'Income'), ('Investment', 'Income'), ('Other Income', 'Income'),
      ('Food', 'Expense'), ('Transport', 'Expense'), ('Rent', 'Expense'), 
      ('Utilities', 'Expense'), ('Healthcare', 'Expense'), ('Education', 'Expense'), 
      ('Shopping', 'Expense'), ('Entertainment', 'Expense'), ('Personal Care', 'Expense'), 
      ('Savings', 'Expense'), ('Other Expense', 'Expense')
    ];

    for (final cat in defaultCategories) {
      if (!existingNames.contains(cat.$1)) {
        await into(categories).insert(CategoriesCompanion(
          name: Value(cat.$1),
          type: Value(cat.$2),
        ));
      }
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
