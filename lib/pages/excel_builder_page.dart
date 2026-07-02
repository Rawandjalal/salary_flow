import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/glass_card.dart';

class ExcelBuilderPage extends StatefulWidget {
  const ExcelBuilderPage({super.key});

  @override
  State<ExcelBuilderPage> createState() => _ExcelBuilderPageState();
}

class _ExcelBuilderPageState extends State<ExcelBuilderPage> {
  String _selectedDateRange = 'All'; // 'All', 'Week', 'Month'
  String _selectedType = 'All'; // 'All', 'Income', 'Expense'
  String _selectedCategory = 'All';
  String _selectedCurrencyFilter = 'All'; // 'All', 'USD', 'IQD'

  final List<String> _categories = [
    'All',
    // Personal
    'Food',
    'Transport',
    'Rent',
    'Entertainment',
    'Shopping',
    'Utilities',
    'Medical',
    'Education',
    'Gift',
    // Business
    'Inventory/Stock',
    'Rent/Office',
    'Marketing/Ads',
    'Salaries/Wages',
    'Software/Tools',
    'Logistics/Shipping',
    'Taxes/Fees',
    'Office Supplies',
    'Sales/Revenue',
    'Service/Consulting',
    'Capital Deposit',
    'Refund/Return',
    'Other'
  ];

  // Selected Columns Map (includes advanced fields by default)
  final Map<String, bool> _columns = {
    'Date': true,
    'Title': true,
    'Reason': true,
    'Category': true,
    'Type': true,
    'Amount': true,
    'Currency': true,
    'Scope': true,
    'Payment Method': true,
    'Contact': true,
    'ID': false,
  };

  DateTimeRange? _getDateRange() {
    final now = DateTime.now();
    if (_selectedDateRange == 'Week') {
      final start = now.subtract(Duration(days: now.weekday - 1));
      final end = start.add(const Duration(days: 6, hours: 23, minutes: 59));
      return DateTimeRange(start: start, end: end);
    }
    if (_selectedDateRange == 'Month') {
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 0, 23, 59);
      return DateTimeRange(start: start, end: end);
    }
    return null;
  }

  void _generateAndCopyTable(BuildContext context, AppState appState) {
    final activeColumns = _columns.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (activeColumns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appState.isRtl ? 'تکایە بەلایەنی کەمەوە یەک ستوون دیاری بکە!' : 'Please select at least one column!'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    final csvString = appState.exportCustomCsv(
      dateRange: _getDateRange(),
      typeFilter: _selectedType,
      categoryFilter: _selectedCategory,
      currencyFilter: _selectedCurrencyFilter,
      selectedColumns: activeColumns,
    );

    Clipboard.setData(ClipboardData(text: csvString));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appState.t('copied')),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  String _getCategoryTranslation(BuildContext context, String category) {
    final appState = Provider.of<AppState>(context, listen: false);
    if (category == 'All') return appState.isRtl ? 'هەموو' : 'All';
    switch (category) {
      case 'Food':
        return appState.t('food');
      case 'Transport':
        return appState.t('transport');
      case 'Rent':
        return appState.t('rent');
      case 'Entertainment':
        return appState.t('entertainment');
      case 'Shopping':
        return appState.t('shopping');
      case 'Utilities':
        return appState.t('utilities');
      case 'Salary':
        return appState.t('salary');
      case 'Medical':
        return appState.t('medical');
      case 'Education':
        return appState.t('education');
      case 'Gift':
        return appState.t('gift');
      case 'Freelance/Side Hustle':
        return appState.t('freelance');
      case 'Investments':
        return appState.t('investments');
      case 'Inventory/Stock':
        return appState.t('inventory');
      case 'Rent/Office':
        return appState.isRtl ? 'کرێ/پسوولە' : 'Rent / Office';
      case 'Marketing/Ads':
        return appState.t('marketing');
      case 'Salaries/Wages':
        return appState.t('salaries');
      case 'Software/Tools':
        return appState.t('software');
      case 'Logistics/Shipping':
        return appState.t('logistics');
      case 'Taxes/Fees':
        return appState.t('taxes');
      case 'Office Supplies':
        return appState.t('office_supplies');
      case 'Sales/Revenue':
        return appState.t('sales_revenue');
      case 'Service/Consulting':
        return appState.t('service_consulting');
      case 'Capital Deposit':
        return appState.t('capital');
      case 'Refund/Return':
        return appState.t('refund');
      default:
        return appState.t('other');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F111E),
        elevation: 0,
        title: Text(
          appState.t('excel_wizard'),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
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
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Column Selector Section
              Text(
                appState.t('select_cols'),
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
                  children: _columns.keys.map((key) {
                    // Translate column names
                    String displayName = key;
                    if (key == 'Reason') displayName = appState.t('reason');
                    if (key == 'Title') displayName = appState.t('title');
                    if (key == 'Amount') displayName = appState.t('amount');
                    if (key == 'Category') displayName = appState.t('category');
                    if (key == 'Type') displayName = appState.t('expense') + ' / ' + appState.t('income');
                    if (key == 'Date') displayName = appState.t('date');
                    if (key == 'Currency') displayName = appState.t('currency');
                    if (key == 'Scope') displayName = appState.t('scope');
                    if (key == 'Payment Method') displayName = appState.t('payment_method');
                    if (key == 'Contact') displayName = appState.t('contact');

                    return CheckboxListTile(
                      title: Text(displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5)),
                      value: _columns[key],
                      activeColor: const Color(0xFF10B981),
                      checkColor: Colors.white,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _columns[key] = val;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Filter Date Range Section
              Text(
                appState.t('date_range'),
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
                  children: [
                    RadioListTile<String>(
                      title: Text(appState.t('all_time'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      value: 'All',
                      groupValue: _selectedDateRange,
                      activeColor: const Color(0xFF10B981),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDateRange = val);
                      },
                    ),
                    RadioListTile<String>(
                      title: Text(appState.t('this_week'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      value: 'Week',
                      groupValue: _selectedDateRange,
                      activeColor: const Color(0xFF10B981),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDateRange = val);
                      },
                    ),
                    RadioListTile<String>(
                      title: Text(appState.t('this_month'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      value: 'Month',
                      groupValue: _selectedDateRange,
                      activeColor: const Color(0xFF10B981),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDateRange = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Advanced Filters (Type, Category, Currency)
              Text(
                appState.isRtl ? 'فلترەکانی تر' : 'ADDITIONAL FILTERS',
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
                  children: [
                    // Type Filter dropdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          appState.isRtl ? 'جۆری مامەڵە' : 'Transaction Type',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        DropdownButton<String>(
                          value: _selectedType,
                          dropdownColor: const Color(0xFF161B2E),
                          underline: const SizedBox(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          items: [
                            DropdownMenuItem(value: 'All', child: Text(appState.isRtl ? 'هەموو' : 'All')),
                            DropdownMenuItem(value: 'Income', child: Text(appState.t('income'))),
                            DropdownMenuItem(value: 'Expense', child: Text(appState.t('expense'))),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedType = val);
                          },
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    // Category Filter dropdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          appState.t('category'),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        DropdownButton<String>(
                          value: _selectedCategory,
                          dropdownColor: const Color(0xFF161B2E),
                          underline: const SizedBox(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          items: _categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(_getCategoryTranslation(context, cat)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCategory = val);
                          },
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    // Currency Filter dropdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          appState.t('currency'),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        DropdownButton<String>(
                          value: _selectedCurrencyFilter,
                          dropdownColor: const Color(0xFF161B2E),
                          underline: const SizedBox(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          items: [
                            DropdownMenuItem(value: 'All', child: Text(appState.isRtl ? 'هەموو' : 'All')),
                            DropdownMenuItem(value: 'USD', child: const Text('USD (\$)')),
                            DropdownMenuItem(value: 'IQD', child: const Text('IQD (د.ع)')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCurrencyFilter = val);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Export Button
              ElevatedButton.icon(
                onPressed: () => _generateAndCopyTable(context, appState),
                icon: const Icon(Icons.table_view_rounded),
                label: Text(appState.t('generate_excel'), style: const TextStyle(fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
