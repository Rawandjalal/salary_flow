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

  String _selectedSettingsCurrency = 'USD'; // 'USD' or 'IQD' configuration active

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _salaryController = TextEditingController(text: appState.salaryConfig.monthlySalaryUSD.toStringAsFixed(2));
    _savingsController = TextEditingController(text: appState.salaryConfig.savingsGoalUSD.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _savingsController.dispose();
    _expenseNameController.dispose();
    _expenseAmountController.dispose();
    super.dispose();
  }

  void _updateControllers(AppState appState) {
    if (_selectedSettingsCurrency == 'USD') {
      _salaryController.text = appState.salaryConfig.monthlySalaryUSD.toStringAsFixed(2);
      _savingsController.text = appState.salaryConfig.savingsGoalUSD.toStringAsFixed(2);
    } else {
      _salaryController.text = appState.salaryConfig.monthlySalaryIQD.toStringAsFixed(0);
      _savingsController.text = appState.salaryConfig.savingsGoalIQD.toStringAsFixed(0);
    }
  }

  void _saveConfigs(BuildContext context, AppState appState) {
    if (!_formKey.currentState!.validate()) return;

    final salary = double.tryParse(_salaryController.text) ?? 0.0;
    final savings = double.tryParse(_savingsController.text) ?? 0.0;

    final newConfig = _selectedSettingsCurrency == 'USD'
        ? appState.salaryConfig.copyWith(
            monthlySalaryUSD: salary,
            savingsGoalUSD: savings,
          )
        : appState.salaryConfig.copyWith(
            monthlySalaryIQD: salary,
            savingsGoalIQD: savings,
          );

    appState.updateSalaryConfig(newConfig);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appState.isRtl ? 'ڕێکخستنەکان بە سەرکەوتوویی پاراستران!' : 'Configuration saved!'),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addFixedExpense(BuildContext context, AppState appState) {
    final activeSymbol = _selectedSettingsCurrency == 'USD' ? '\$' : 'د.ع';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161B2E),
          title: Text(
            appState.t('add_bill'),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _expenseNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: appState.t('bill_name'),
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _expenseAmountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '${appState.t('amount')} ($activeSymbol)',
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
              child: Text(appState.t('cancel'), style: const TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _expenseNameController.text.trim();
                final amount = double.tryParse(_expenseAmountController.text) ?? 0.0;

                if (name.isNotEmpty && amount > 0) {
                  final isUsd = _selectedSettingsCurrency == 'USD';
                  final Map<String, double> updatedExpenses = isUsd
                      ? Map.from(appState.salaryConfig.fixedExpensesUSD)
                      : Map.from(appState.salaryConfig.fixedExpensesIQD);
                  updatedExpenses[name] = amount;

                  final newConfig = isUsd
                      ? appState.salaryConfig.copyWith(fixedExpensesUSD: updatedExpenses)
                      : appState.salaryConfig.copyWith(fixedExpensesIQD: updatedExpenses);
                  
                  appState.updateSalaryConfig(newConfig);

                  _expenseNameController.clear();
                  _expenseAmountController.clear();
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              child: Text(appState.t('add')),
            ),
          ],
        );
      },
    );
  }

  void _removeFixedExpense(BuildContext context, AppState appState, String key) {
    final isUsd = _selectedSettingsCurrency == 'USD';
    final Map<String, double> updatedExpenses = isUsd
        ? Map.from(appState.salaryConfig.fixedExpensesUSD)
        : Map.from(appState.salaryConfig.fixedExpensesIQD);
    updatedExpenses.remove(key);

    final newConfig = isUsd
        ? appState.salaryConfig.copyWith(fixedExpensesUSD: updatedExpenses)
        : appState.salaryConfig.copyWith(fixedExpensesIQD: updatedExpenses);
    
    appState.updateSalaryConfig(newConfig);
  }

  void _resetApp(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161B2E),
          title: Text(appState.t('reset_confirm'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(
            appState.t('reset_warning'),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(appState.t('cancel'), style: const TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              onPressed: () {
                appState.clearAllData();
                setState(() {
                  _salaryController.text = '0.00';
                  _savingsController.text = '0.00';
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(appState.isRtl ? 'داتاکان سڕدرانەوە' : 'App data cleared.'),
                    backgroundColor: const Color(0xFFEF4444),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              child: Text(appState.t('clear_all')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final isUsd = _selectedSettingsCurrency == 'USD';
    final activeSymbol = isUsd ? '\$' : 'د.ع';
    final activeDecimals = isUsd ? 2 : 0;

    final currencyFormat = NumberFormat.currency(
      symbol: activeSymbol,
      decimalDigits: activeDecimals,
    );

    final fixedExpensesList = isUsd
        ? appState.salaryConfig.fixedExpensesUSD
        : appState.salaryConfig.fixedExpensesIQD;

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
                Text(
                  appState.t('settings'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 18),

                // REGIONAL & LANGUAGE SETTINGS
                Text(
                  appState.isRtl ? 'ڕێکخستنی زمان' : 'REGIONAL & LANGUAGE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withOpacity(0.4),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        appState.t('language'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                      DropdownButton<String>(
                        value: appState.salaryConfig.language,
                        dropdownColor: const Color(0xFF161B2E),
                        underline: const SizedBox(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        items: const [
                          DropdownMenuItem(value: 'en', child: Text('English')),
                          DropdownMenuItem(value: 'ku', child: Text('کوردی سۆرانی')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            final newConfig = appState.salaryConfig.copyWith(language: val);
                            appState.updateSalaryConfig(newConfig);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Premium Multi-Currency Wallet Toggle
                Text(
                  appState.isRtl ? 'ڕێکخستنی دەفتەری پارە' : 'WALLET CONFIGURATION TARGET',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withOpacity(0.4),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSettingsCurrency = 'USD';
                              _updateControllers(appState);
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isUsd ? Colors.white.withOpacity(0.08) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              appState.isRtl ? 'ڕێکخستنی دۆلار (\$)' : 'Configure USD (\$)',
                              style: TextStyle(
                                color: isUsd ? Colors.white : Colors.white.withOpacity(0.4),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSettingsCurrency = 'IQD';
                              _updateControllers(appState);
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !isUsd ? Colors.white.withOpacity(0.08) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              appState.isRtl ? 'ڕێکخستنی دینار (د.ع)' : 'Configure IQD (د.ع)',
                              style: TextStyle(
                                color: !isUsd ? Colors.white : Colors.white.withOpacity(0.4),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Salary & Savings Goal Section
                Text(
                  isUsd
                      ? (appState.isRtl ? 'داهات و پاشەکەوت (\$)' : 'SALARY & SAVINGS (USD)')
                      : (appState.isRtl ? 'داهات و پاشەکەوت (د.ع)' : 'SALARY & SAVINGS (IQD)'),
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
                          labelText: '${appState.t('net_salary')} ($activeSymbol)',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                          prefixIcon: Icon(Icons.wallet_rounded, color: Colors.white.withOpacity(0.4)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.04),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return appState.isRtl ? 'تکایە مووچە بنووسە' : 'Enter salary';
                          }
                          if (double.tryParse(val) == null) {
                            return appState.isRtl ? 'تکایە ژمارە بنووسە' : 'Enter a number';
                          }
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
                          labelText: '${appState.t('savings_target')} ($activeSymbol)',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                          prefixIcon: Icon(Icons.savings_rounded, color: Colors.white.withOpacity(0.4)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.04),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return appState.isRtl ? 'تکایە پاشەکەوت بنووسە' : 'Enter savings goal';
                          }
                          if (double.tryParse(val) == null) {
                            return appState.isRtl ? 'تکایە ژمارە بنووسە' : 'Enter a number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _saveConfigs(context, appState),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text(appState.t('save_settings'), style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Fixed Monthly Bills/Expenses (USD vs IQD)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${appState.t('fixed_bills')} ($activeSymbol)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.4),
                        letterSpacing: 1.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF10B981), size: 24),
                      onPressed: () => _addFixedExpense(context, appState),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (fixedExpensesList.isEmpty)
                  GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        appState.t('no_bills'),
                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                else
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: fixedExpensesList.entries.map((entry) {
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
                                    onPressed: () => _removeFixedExpense(context, appState, entry.key),
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

                // System Data Area
                Text(
                  appState.t('system_data'),
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
                        onPressed: () => _resetApp(context, appState),
                        icon: const Icon(Icons.delete_forever_rounded, size: 20),
                        label: Text(appState.t('reset_app'), style: const TextStyle(fontWeight: FontWeight.w700)),
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
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
