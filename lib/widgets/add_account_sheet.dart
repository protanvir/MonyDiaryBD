import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../providers/database_provider.dart';
import '../data/database.dart';

class AddAccountSheet extends ConsumerStatefulWidget {
  final Account? initialAccount;
  const AddAccountSheet({super.key, this.initialAccount});

  @override
  ConsumerState<AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends ConsumerState<AddAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _type;
  late double _balance;
  
  final List<String> _accountTypes = ['Cash', 'Bank', 'bKash', 'Nagad', 'Rocket', 'CreditCard'];

  @override
  void initState() {
    super.initState();
    _name = widget.initialAccount?.name ?? '';
    _type = widget.initialAccount?.type ?? 'Cash';
    _balance = widget.initialAccount?.initialBalance ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.initialAccount != null;
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing ? 'Edit Account' : 'Add New Account',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              initialValue: _name,
              decoration: InputDecoration(
                labelText: 'Account Name',
                hintText: 'e.g. Physical Wallet, DBBL...',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              onSaved: (val) => _name = val ?? '',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: InputDecoration(
                labelText: 'Account Type',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              items: _accountTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => setState(() => _type = val!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _balance.toStringAsFixed(0),
              decoration: InputDecoration(
                labelText: _type == 'CreditCard' ? 'Credit Limit (৳)' : 'Initial Balance (৳)',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Required';
                if (double.tryParse(val) == null) return 'Must be a number';
                return null;
              },
              onSaved: (val) => _balance = double.parse(val!),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  
                  final db = ref.read(databaseProvider);
                  if (isEditing) {
                    await db.updateAccount(widget.initialAccount!.copyWith(
                      name: _name,
                      type: _type,
                      initialBalance: _balance,
                    ));
                  } else {
                    await db.addAccount(AccountsCompanion(
                      name: drift.Value(_name),
                      type: drift.Value(_type),
                      initialBalance: drift.Value(_balance),
                    ));
                  }
                  
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(isEditing ? 'Update Account' : 'Save Account', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
