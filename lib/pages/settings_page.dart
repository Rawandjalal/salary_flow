import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../widgets/glass_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _salaryController;
  late TextEditingController _savingsController;

  final _expenseNameController = TextEditingController();
  final _expenseAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _salaryController = TextEditingController(text: appState.salaryConfig.monthlySalary.toStringAsFixed(2));
    _savingsController = TextEditingController(text: appState.salaryConfig.savingsGoal.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _savingsController.dispose();
    _expenseNameController.dispose();
    _expenseAmountController.dispose();
    super.dispose();
  }

  void _saveConfigs(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final appState = Provider.of<AppState>(context, listen: false);
    final salary = double.tryParse(_salaryController.text) ?? 0.0;
    final savings = double.tryParse(_savingsController.text) ?? 0.0;

    final newConfig = appState.salaryConfig.copyWith(
      monthlySalary: salary,
      savingsGoal: savings,
    );

    appState.updateSalaryConfig(newConfig);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuration saved!'),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _addFixedExpense(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161B2E),
          title: const Text(
            'Add Fixed Bill',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _expenseNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Bill Name (e.g. Rent, Internet)',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _expenseAmountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Amount (\$)',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _expenseNameController.clear();
                _expenseAmountController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _expenseNameController.text.trim();
                final amount = double.tryParse(_expenseAmountController.text) ?? 0.0;

                if (name.isNotEmpty && amount > 0) {
                  final appState = Provider.of<AppState>(context, listen: false);
                  final Map<String, double> updatedExpenses = Map.from(appState.salaryConfig.fixedExpenses);
                  updatedExpenses[name] = amount;

                  final newConfig = appState.salaryConfig.copyWith(fixedExpenses: updatedExpenses);
                  appState.updateSalaryConfig(newConfig);

                  _expenseNameController.clear();
                  _expenseAmountController.clear();
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeFixedExpense(BuildContext context, String key) {
    final appState = Provider.of<AppState>(context, listen: false);
    final Map<String, double> updatedExpenses = Map.from(appState.salaryConfig.fixedExpenses);
    updatedExpenses.remove(key);

    final newConfig = appState.salaryConfig.copyWith(fixedExpenses: updatedExpenses);
    appState.updateSalaryConfig(newConfig);
  }

  void _resetApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161B2E),
          title: const Text('Reset All Data?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text(
            'This will permanently delete all salary configurations, fixed bills, and transactions. This action cannot be undone.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              onPressed: () {
                final appState = Provider.of<AppState>(context, listen: false);
                appState.clearAllData();
                setState(() {
                  _salaryController.text = '0.00';
                  _savingsController.text = '0.00';
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('App data cleared.'),
                    backgroundColor: Color(0xFFEF4444),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currencyFormat = NumberFormat.simpleCurrency();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F111E),
              Color(0xFF07080F),
            ],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Salary & Savings Goal Section
                Text(
                  'SALARY & SAVINGS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withOpacity(0.4),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Salary Field
                      TextFormField(
                        controller: _salaryController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          labelText: 'Net Monthly Salary (\$)',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                          prefixIcon: Icon(Icons.wallet_rounded, color: Colors.white.withOpacity(0.4)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.04),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Enter salary';
                          if (double.tryParse(val) == null) return 'Enter a number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Savings Goal Field
                      TextFormField(
                        controller: _savingsController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          labelText: 'Monthly Savings Target (\$)',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                          prefixIcon: Icon(Icons.savings_rounded, color: Colors.white.withOpacity(0.4)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.04),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Enter savings goal';
                          if (double.tryParse(val) == null) return 'Enter a number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _saveConfigs(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text('Save Salary Settings', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Fixed Monthly Bills/Expenses
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'FIXED MONTHLY BILLS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.4),
                        letterSpacing: 1.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF10B981), size: 24),
                      onPressed: () => _addFixedExpense(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (appState.salaryConfig.fixedExpenses.isEmpty)
                  GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No fixed bills configured yet.',
                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                else
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: appState.salaryConfig.fixedExpenses.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              Row(
                                children: [
                                  Text(
                                    currencyFormat.format(entry.value),
                                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline_rounded, color: const Color(0xFFEF4444).withOpacity(0.8), size: 20),
                                    onPressed: () => _removeFixedExpense(context, entry.key),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 36),

                // Dangerous Area
                Text(
                  'SYSTEM DATA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withOpacity(0.4),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _resetApp(context),
                        icon: const Icon(Icons.delete_forever_rounded, size: 20),
                        label: const Text('Reset All Application Data', style: TextStyle(fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: const Color(0xFFEF4444),
                          shadowColor: Colors.transparent,
                          side: BorderSide(color: const Color(0xFFEF4444).withOpacity(0.4), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
