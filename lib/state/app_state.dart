import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/salary_config.dart';
import '../models/staff_member.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storageService;

  List<Transaction> _transactions = [];
  SalaryConfig _salaryConfig = SalaryConfig();
  bool _isLoading = true;

  // Global Scope Filter: 'all', 'personal', 'business'
  String _selectedScope = 'all';
  String _geminiApiKey = '';

  List<StaffMember> _staffMembers = [];
  List<PayrollRecord> _payrollRecords = [];

  // Widget customizer states
  double _widgetQuickAdd1 = 20.0;
  double _widgetQuickAdd2 = 50.0;
  double _widgetQuickSub1 = 10.0;
  double _widgetQuickSub2 = 25.0;
  String _widgetStyle = 'Glassmorphism';

  AppState(this._storageService) {
    _loadFromStorage();
  }

  bool get isLoading => _isLoading;
  String get geminiApiKey => _geminiApiKey;
  List<StaffMember> get staffMembers => _staffMembers;
  List<PayrollRecord> get payrollRecords => _payrollRecords;
  
  double get widgetQuickAdd1 => _widgetQuickAdd1;
  double get widgetQuickAdd2 => _widgetQuickAdd2;
  double get widgetQuickSub1 => _widgetQuickSub1;
  double get widgetQuickSub2 => _widgetQuickSub2;
  String get widgetStyle => _widgetStyle;

  void setGeminiApiKey(String key) {
    _geminiApiKey = key;
    _storageService.saveString('gemini_api_key', key);
    notifyListeners();
  }

  Future<void> updateWidgetStyle(String style) async {
    _widgetStyle = style;
    await _storageService.saveString('widget_style', style);
    notifyListeners();
  }

  Future<void> saveWidgetPresets({
    required double quickAdd1,
    required double quickAdd2,
    required double quickSub1,
    required double quickSub2,
  }) async {
    _widgetQuickAdd1 = quickAdd1;
    _widgetQuickAdd2 = quickAdd2;
    _widgetQuickSub1 = quickSub1;
    _widgetQuickSub2 = quickSub2;
    await _storageService.saveDouble('widget_quick_add1', quickAdd1);
    await _storageService.saveDouble('widget_quick_add2', quickAdd2);
    await _storageService.saveDouble('widget_quick_sub1', quickSub1);
    await _storageService.saveDouble('widget_quick_sub2', quickSub2);
    notifyListeners();
  }
  
  // Filtered transactions for UI usage
  List<Transaction> get transactions => _transactions.where(_matchesScope).toList();
  
  // All transactions (raw) for backend or full reports
  List<Transaction> get allTransactions => _transactions;

  SalaryConfig get salaryConfig => _salaryConfig;
  String get selectedScope => _selectedScope;

  // Language Preference
  bool get isRtl => _salaryConfig.language == 'ku';

  void setSelectedScope(String scope) {
    if (_selectedScope != scope) {
      _selectedScope = scope;
      notifyListeners();
    }
  }

  void _loadFromStorage() {
    _transactions = _storageService.getTransactions();
    _salaryConfig = _storageService.getSalaryConfig();
    _geminiApiKey = _storageService.getString('gemini_api_key') ?? '';
    
    _widgetQuickAdd1 = _storageService.getDouble('widget_quick_add1') ?? 20.0;
    _widgetQuickAdd2 = _storageService.getDouble('widget_quick_add2') ?? 50.0;
    _widgetQuickSub1 = _storageService.getDouble('widget_quick_sub1') ?? 10.0;
    _widgetQuickSub2 = _storageService.getDouble('widget_quick_sub2') ?? 25.0;
    _widgetStyle = _storageService.getString('widget_style') ?? 'Glassmorphism';
    
    final staffStr = _storageService.getString('staff_members');
    if (staffStr != null && staffStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(staffStr) as List;
        _staffMembers = decoded.map((e) => StaffMember.fromJson(e)).toList();
      } catch (_) {}
    }
    
    final payrollStr = _storageService.getString('payroll_records');
    if (payrollStr != null && payrollStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(payrollStr) as List;
        _payrollRecords = decoded.map((e) => PayrollRecord.fromJson(e)).toList();
      } catch (_) {}
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateSalaryConfig(SalaryConfig config) async {
    _salaryConfig = config;
    await _storageService.saveSalaryConfig(_salaryConfig);
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    _transactions.insert(0, transaction);
    await _storageService.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((tx) => tx.id == id);
    await _storageService.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> _saveStaffMembers() async {
    final str = jsonEncode(_staffMembers.map((e) => e.toJson()).toList());
    await _storageService.saveString('staff_members', str);
  }

  Future<void> _savePayrollRecords() async {
    final str = jsonEncode(_payrollRecords.map((e) => e.toJson()).toList());
    await _storageService.saveString('payroll_records', str);
  }

  Future<void> addStaffMember(StaffMember member) async {
    _staffMembers.add(member);
    await _saveStaffMembers();
    notifyListeners();
  }

  Future<void> deleteStaffMember(String id) async {
    _staffMembers.removeWhere((e) => e.id == id);
    _payrollRecords.removeWhere((e) => e.staffId == id);
    await _saveStaffMembers();
    await _savePayrollRecords();
    notifyListeners();
  }

  Future<void> updateStaffMember(StaffMember member) async {
    final idx = _staffMembers.indexWhere((e) => e.id == member.id);
    if (idx != -1) {
      _staffMembers[idx] = member;
      await _saveStaffMembers();
      notifyListeners();
    }
  }

  Future<void> logDailyPayroll(DateTime date, List<PayrollRecord> records) async {
    // 1. Remove existing payroll logs for this date to avoid duplicates
    final dateStr = date.toIso8601String().substring(0, 10);
    _payrollRecords.removeWhere((e) => e.date.toIso8601String().substring(0, 10) == dateStr);

    // 2. Add the new logs
    _payrollRecords.addAll(records);
    await _savePayrollRecords();

    // 3. Automatically add to general ledger expenses
    for (final record in records) {
      if (record.amount > 0 && record.status != 'absent') {
        final tx = Transaction(
          id: 'payroll_${record.id}_${DateTime.now().millisecondsSinceEpoch}',
          title: isRtl ? 'مووچە: ${record.staffName}' : 'Payroll: ${record.staffName}',
          amount: record.amount,
          currency: record.currency,
          category: 'salaries',
          date: date,
          isIncome: false,
          scope: 'business',
          paymentMethod: 'cash',
          contact: record.staffName,
          description: isRtl 
              ? 'تۆمارکرا بە شێوەی ئۆتۆماتیکی لە ڕێگەی لیستی مووچەی ڕۆژانە. بارودۆخ: ${record.status}' 
              : 'Automatically generated via Daily Payroll table. Status: ${record.status}',
        );
        await addTransaction(tx);
      }
    }

    notifyListeners();
  }

  Future<void> clearAllData() async {
    _transactions.clear();
    _salaryConfig = SalaryConfig();
    _geminiApiKey = '';
    await _storageService.clearAll();
    await _storageService.saveString('gemini_api_key', '');
    notifyListeners();
  }

  // Helper to match selected scope
  bool _matchesScope(Transaction tx) {
    if (_selectedScope == 'all') return true;
    return tx.scope == _selectedScope;
  }

  // ----------------------------------------------------
  // CALENDAR DATE HELPERS
  // ----------------------------------------------------
  int get daysInMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0).day;
  }

  int get remainingDaysInMonth {
    final now = DateTime.now();
    return daysInMonth - now.day + 1;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  // ----------------------------------------------------
  // PARALLEL LEDGERS / WALLETS METRICS (USD & IQD)
  // ----------------------------------------------------

  // 1. Daily Allowance (checks manual setting or auto-calculates)
  double get dailyAllowanceUSD {
    if (_selectedScope == 'personal') {
      if (_salaryConfig.useManualDailyBudget) {
        return _salaryConfig.personalDailyBudgetUSD;
      }
      final disposable = _salaryConfig.netDisposableIncomeUSD;
      return disposable <= 0 ? 0.0 : disposable / daysInMonth;
    } else if (_selectedScope == 'business') {
      if (_salaryConfig.useManualDailyBudget) {
        return _salaryConfig.businessDailyBudgetUSD;
      }
      final disposable = _salaryConfig.netBusinessDisposableIncomeUSD;
      return disposable <= 0 ? 0.0 : disposable / daysInMonth;
    } else {
      // Combined scope
      double personalAllowance = 0.0;
      double businessAllowance = 0.0;

      if (_salaryConfig.useManualDailyBudget) {
        personalAllowance = _salaryConfig.personalDailyBudgetUSD;
        businessAllowance = _salaryConfig.businessDailyBudgetUSD;
      } else {
        final personalDisposable = _salaryConfig.netDisposableIncomeUSD;
        final businessDisposable = _salaryConfig.netBusinessDisposableIncomeUSD;
        personalAllowance = personalDisposable <= 0 ? 0.0 : personalDisposable / daysInMonth;
        businessAllowance = businessDisposable <= 0 ? 0.0 : businessDisposable / daysInMonth;
      }
      return personalAllowance + businessAllowance;
    }
  }

  double get dailyAllowanceIQD {
    if (_selectedScope == 'personal') {
      if (_salaryConfig.useManualDailyBudget) {
        return _salaryConfig.personalDailyBudgetIQD;
      }
      final disposable = _salaryConfig.netDisposableIncomeIQD;
      return disposable <= 0 ? 0.0 : disposable / daysInMonth;
    } else if (_selectedScope == 'business') {
      if (_salaryConfig.useManualDailyBudget) {
        return _salaryConfig.businessDailyBudgetIQD;
      }
      final disposable = _salaryConfig.netBusinessDisposableIncomeIQD;
      return disposable <= 0 ? 0.0 : disposable / daysInMonth;
    } else {
      // Combined scope
      double personalAllowance = 0.0;
      double businessAllowance = 0.0;

      if (_salaryConfig.useManualDailyBudget) {
        personalAllowance = _salaryConfig.personalDailyBudgetIQD;
        businessAllowance = _salaryConfig.businessDailyBudgetIQD;
      } else {
        final personalDisposable = _salaryConfig.netDisposableIncomeIQD;
        final businessDisposable = _salaryConfig.netBusinessDisposableIncomeIQD;
        personalAllowance = personalDisposable <= 0 ? 0.0 : personalDisposable / daysInMonth;
        businessAllowance = businessDisposable <= 0 ? 0.0 : businessDisposable / daysInMonth;
      }
      return personalAllowance + businessAllowance;
    }
  }

  // 2. Today's Expenses
  double get todaysExpensesUSD {
    return _transactions
        .where((tx) => !tx.isIncome && tx.currency == 'USD' && _isToday(tx.date) && _matchesScope(tx))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get todaysExpensesIQD {
    return _transactions
        .where((tx) => !tx.isIncome && tx.currency == 'IQD' && _isToday(tx.date) && _matchesScope(tx))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // 3. Today's Income
  double get todaysIncomeUSD {
    return _transactions
        .where((tx) => tx.isIncome && tx.currency == 'USD' && _isToday(tx.date) && _matchesScope(tx))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get todaysIncomeIQD {
    return _transactions
        .where((tx) => tx.isIncome && tx.currency == 'IQD' && _isToday(tx.date) && _matchesScope(tx))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // 4. Remaining Daily Budget
  double get remainingDailyBudgetUSD {
    return dailyAllowanceUSD + todaysIncomeUSD - todaysExpensesUSD;
  }

  double get remainingDailyBudgetIQD {
    return dailyAllowanceIQD + todaysIncomeIQD - todaysExpensesIQD;
  }

  // 5. Budget Usage Ratio
  double get budgetUsageRatioUSD {
    final totalAllowance = dailyAllowanceUSD + todaysIncomeUSD;
    if (totalAllowance <= 0) return 1.0;
    final ratio = todaysExpensesUSD / totalAllowance;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  double get budgetUsageRatioIQD {
    final totalAllowance = dailyAllowanceIQD + todaysIncomeIQD;
    if (totalAllowance <= 0) return 1.0;
    final ratio = todaysExpensesIQD / totalAllowance;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  // 6. Monthly Expenses So Far
  double get monthlyExpensesSoFarUSD {
    return _transactions
        .where((tx) => !tx.isIncome && tx.currency == 'USD' && _isThisMonth(tx.date) && _matchesScope(tx))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get monthlyExpensesSoFarIQD {
    return _transactions
        .where((tx) => !tx.isIncome && tx.currency == 'IQD' && _isThisMonth(tx.date) && _matchesScope(tx))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // 7. Monthly Additional Income
  double get monthlyAdditionalIncomeUSD {
    return _transactions
        .where((tx) => tx.isIncome && tx.currency == 'USD' && _isThisMonth(tx.date) && _matchesScope(tx))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get monthlyAdditionalIncomeIQD {
    return _transactions
        .where((tx) => tx.isIncome && tx.currency == 'IQD' && _isThisMonth(tx.date) && _matchesScope(tx))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // 8. Total Monthly Expenses (So Far + Fixed Bills)
  double get totalMonthlyExpensesUSD {
    if (_selectedScope == 'personal') {
      return monthlyExpensesSoFarUSD + _salaryConfig.totalFixedExpensesUSD;
    } else if (_selectedScope == 'business') {
      return monthlyExpensesSoFarUSD + _salaryConfig.totalBusinessFixedExpensesUSD;
    } else {
      return monthlyExpensesSoFarUSD + _salaryConfig.totalFixedExpensesUSD + _salaryConfig.totalBusinessFixedExpensesUSD;
    }
  }

  double get totalMonthlyExpensesIQD {
    if (_selectedScope == 'personal') {
      return monthlyExpensesSoFarIQD + _salaryConfig.totalFixedExpensesIQD;
    } else if (_selectedScope == 'business') {
      return monthlyExpensesSoFarIQD + _salaryConfig.totalBusinessFixedExpensesIQD;
    } else {
      return monthlyExpensesSoFarIQD + _salaryConfig.totalFixedExpensesIQD + _salaryConfig.totalBusinessFixedExpensesIQD;
    }
  }

  // 9. Total Monthly Income (Salary/Base + Additional Incomes)
  double get totalMonthlyIncomeUSD {
    if (_selectedScope == 'personal') {
      return _salaryConfig.monthlySalaryUSD + monthlyAdditionalIncomeUSD;
    } else if (_selectedScope == 'business') {
      return _salaryConfig.businessIncomeUSD + monthlyAdditionalIncomeUSD;
    } else {
      return _salaryConfig.monthlySalaryUSD + _salaryConfig.businessIncomeUSD + monthlyAdditionalIncomeUSD;
    }
  }

  double get totalMonthlyIncomeIQD {
    if (_selectedScope == 'personal') {
      return _salaryConfig.monthlySalaryIQD + monthlyAdditionalIncomeIQD;
    } else if (_selectedScope == 'business') {
      return _salaryConfig.businessIncomeIQD + monthlyAdditionalIncomeIQD;
    } else {
      return _salaryConfig.monthlySalaryIQD + _salaryConfig.businessIncomeIQD + monthlyAdditionalIncomeIQD;
    }
  }

  // 10. Net Realized Savings
  double get monthlySavingsRealizedUSD {
    final net = totalMonthlyIncomeUSD - totalMonthlyExpensesUSD;
    return net > 0 ? net : 0.0;
  }

  double get monthlySavingsRealizedIQD {
    final net = totalMonthlyIncomeIQD - totalMonthlyExpensesIQD;
    return net > 0 ? net : 0.0;
  }

  // 11. Spending Velocity (average daily outflow rate)
  double get spendVelocityUSD {
    final currentDay = DateTime.now().day;
    final totalSpent = monthlyExpensesSoFarUSD;
    return currentDay > 0 ? totalSpent / currentDay : totalSpent;
  }

  double get spendVelocityIQD {
    final currentDay = DateTime.now().day;
    final totalSpent = monthlyExpensesSoFarIQD;
    return currentDay > 0 ? totalSpent / currentDay : totalSpent;
  }

  // 12. Remaining Disposable Balance
  double get remainingDisposableBalanceUSD {
    final balance = totalMonthlyIncomeUSD - totalMonthlyExpensesUSD;
    return balance > 0 ? balance : 0.0;
  }

  double get remainingDisposableBalanceIQD {
    final balance = totalMonthlyIncomeIQD - totalMonthlyExpensesIQD;
    return balance > 0 ? balance : 0.0;
  }

  // 13. Runway Forecast
  int get runwayForecastDaysUSD {
    final velocity = spendVelocityUSD;
    if (velocity <= 0) return 999;
    final days = (remainingDisposableBalanceUSD / velocity).round();
    return days > 999 ? 999 : days;
  }

  int get runwayForecastDaysIQD {
    final velocity = spendVelocityIQD;
    if (velocity <= 0) return 999;
    final days = (remainingDisposableBalanceIQD / velocity).round();
    return days > 999 ? 999 : days;
  }

  // 14. Financial Health Score (0-100)
  int get financialHealthScoreUSD {
    final income = totalMonthlyIncomeUSD;
    if (income <= 0) return 0;
    final expense = totalMonthlyExpensesUSD;

    final savingsRatio = (income - expense) / income;
    final savingsScore = (savingsRatio / 0.20).clamp(0.0, 1.0) * 40;

    final fixedBillsTotal = _selectedScope == 'business'
        ? _salaryConfig.totalBusinessFixedExpensesUSD
        : (_selectedScope == 'personal'
            ? _salaryConfig.totalFixedExpensesUSD
            : (_salaryConfig.totalFixedExpensesUSD + _salaryConfig.totalBusinessFixedExpensesUSD));

    final fixedRatio = fixedBillsTotal / income;
    final fixedScore = (1.0 - (fixedRatio / 0.60)).clamp(0.0, 1.0) * 30;

    final dailyRatio = todaysExpensesUSD / (dailyAllowanceUSD > 0 ? dailyAllowanceUSD : 1.0);
    final disciplineScore = (2.0 - dailyRatio).clamp(0.0, 2.0) / 2.0 * 30;

    return (savingsScore + fixedScore + disciplineScore).round();
  }

  int get financialHealthScoreIQD {
    final income = totalMonthlyIncomeIQD;
    if (income <= 0) return 0;
    final expense = totalMonthlyExpensesIQD;

    final savingsRatio = (income - expense) / income;
    final savingsScore = (savingsRatio / 0.20).clamp(0.0, 1.0) * 40;

    final fixedBillsTotal = _selectedScope == 'business'
        ? _salaryConfig.totalBusinessFixedExpensesIQD
        : (_selectedScope == 'personal'
            ? _salaryConfig.totalFixedExpensesIQD
            : (_salaryConfig.totalFixedExpensesIQD + _salaryConfig.totalBusinessFixedExpensesIQD));

    final fixedRatio = fixedBillsTotal / income;
    final fixedScore = (1.0 - (fixedRatio / 0.60)).clamp(0.0, 1.0) * 30;

    final dailyRatio = todaysExpensesIQD / (dailyAllowanceIQD > 0 ? dailyAllowanceIQD : 1.0);
    final disciplineScore = (2.0 - dailyRatio).clamp(0.0, 2.0) / 2.0 * 30;

    return (savingsScore + fixedScore + disciplineScore).round();
  }

  // 15. Spend Breakdown by Category
  Map<String, double> getCategoryExpensesBreakdown(String currency) {
    final breakdown = <String, double>{};
    for (var tx in _transactions) {
      if (!tx.isIncome && tx.currency == currency && _isThisMonth(tx.date) && _matchesScope(tx)) {
        breakdown[tx.category] = (breakdown[tx.category] ?? 0.0) + tx.amount;
      }
    }
    return breakdown;
  }

  // ----------------------------------------------------
  // EXPORT WIZARD & SPREADSHEET BUILDER
  // ----------------------------------------------------

  String exportCustomCsv({
    DateTimeRange? dateRange,
    String? typeFilter,
    String? categoryFilter,
    String? currencyFilter, // 'All', 'USD', 'IQD'
    required List<String> selectedColumns,
  }) {
    final buffer = StringBuffer();

    // Column Headers Row
    final headers = selectedColumns.map((col) {
      if (col == 'Reason') return isRtl ? 'بۆچی (هۆکار)' : 'Reason/Why';
      if (col == 'Title') return isRtl ? 'ناونیشان' : 'Title';
      if (col == 'Amount') return isRtl ? 'بڕ' : 'Amount';
      if (col == 'Category') return isRtl ? 'پۆلێن' : 'Category';
      if (col == 'Type') return isRtl ? 'جۆر' : 'Type';
      if (col == 'Date') return isRtl ? 'ڕێکەوت' : 'Date';
      if (col == 'Currency') return isRtl ? 'دراو' : 'Currency';
      if (col == 'Scope') return isRtl ? 'بوار (کەسی/کار)' : 'Scope';
      if (col == 'Payment Method') return isRtl ? 'ڕێگای پارەدان' : 'Payment Method';
      if (col == 'Contact') return isRtl ? 'ناو / پەیوەندی' : 'Contact';
      return col;
    }).join(',');
    buffer.writeln(headers);

    // Filter List (runs against all raw transactions)
    final filteredList = _transactions.where((tx) {
      if (dateRange != null) {
        if (tx.date.isBefore(dateRange.start) || tx.date.isAfter(dateRange.end)) {
          return false;
        }
      }
      if (typeFilter != null && typeFilter != 'All') {
        if (typeFilter == 'Income' && !tx.isIncome) return false;
        if (typeFilter == 'Expense' && tx.isIncome) return false;
      }
      if (categoryFilter != null && categoryFilter != 'All') {
        if (tx.category != categoryFilter) return false;
      }
      if (currencyFilter != null && currencyFilter != 'All') {
        if (tx.currency != currencyFilter) return false;
      }
      if (!_matchesScope(tx)) return false;
      return true;
    }).toList();

    // Data Row Output
    for (var tx in filteredList) {
      final row = selectedColumns.map((col) {
        if (col == 'ID') return tx.id;
        if (col == 'Date') return tx.date.toIso8601String().substring(0, 10);
        if (col == 'Title') return tx.title.replaceAll(',', ' ');
        if (col == 'Reason') return tx.description.replaceAll(',', ' ');
        if (col == 'Category') return tx.category;
        if (col == 'Type') return tx.isIncome ? 'Income' : 'Expense';
        if (col == 'Amount') return tx.amount.toStringAsFixed(2);
        if (col == 'Currency') return tx.currency;
        if (col == 'Scope') return tx.scope;
        if (col == 'Payment Method') return tx.paymentMethod;
        if (col == 'Contact') return tx.contact.replaceAll(',', ' ');
        return '';
      }).join(',');
      buffer.writeln(row);
    }

    return buffer.toString();
  }

  String exportToCsv() {
    return exportCustomCsv(
      selectedColumns: ['Date', 'Title', 'Reason', 'Category', 'Type', 'Amount', 'Currency', 'Scope', 'Payment Method', 'Contact'],
    );
  }

  // ----------------------------------------------------
  // LOCALIZATION SYSTEM
  // ----------------------------------------------------
  
  String t(String key) {
    final lang = _salaryConfig.language;
    return _localizedStrings[lang]?[key] ?? _localizedStrings['en']?[key] ?? key;
  }

  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'app_title': 'SalaryFlow',
      'welcome_back': 'WELCOME BACK',
      'manager_title': 'SalaryFlow Manager',
      'remaining_budget': 'BUDGET LEFT',
      'exceeded_by': 'EXCEEDED BY',
      'allowance': 'Allowance',
      'todays_spent': "TODAY'S SPENT",
      'todays_income': "TODAY'S INCOME",
      'quick_log': 'QUICK LOG EXPENSE',
      'recent_transactions': 'RECENT TRANSACTIONS',
      'see_all': 'See All',
      'no_transactions': 'No transactions logged yet',
      'tap_add': 'Tap the + button to add one',
      'new_transaction': 'New Transaction',
      'title': 'Title',
      'amount': 'Amount',
      'category': 'Category',
      'date': 'Date',
      'add_transaction': 'Add Transaction',
      'expense': 'Expense',
      'income': 'Income',
      'salary': 'Salary',
      'other': 'Other',
      'analysis': 'Analysis',
      'settings': 'Settings',
      'net_salary': 'Net Monthly Salary / Revenue',
      'savings_target': 'Monthly Savings / Profit Target',
      'save_settings': 'Save Configuration',
      'fixed_bills': 'FIXED MONTHLY BILLS',
      'no_bills': 'No fixed bills configured yet.',
      'add_bill': 'Add Fixed Bill',
      'bill_name': 'Bill Name (e.g. Rent, Internet)',
      'system_data': 'SYSTEM DATA',
      'reset_app': 'Reset All Application Data',
      'language': 'Language',
      'currency': 'Currency',
      'financial_health': 'FINANCIAL HEALTH',
      'health_score': 'Financial Health Score',
      'burn_rate': 'Income Consumed',
      'spending_breakdown': 'SPENDING BREAKDOWN',
      'no_expense_data': 'No expense data to analyze yet',
      'cash_flow': 'MONTHLY CASH FLOW',
      'flow_income': 'Total Income',
      'flow_spend': 'Total Spend',
      'flow_savings': 'Net Savings',
      'runway_card': 'RUNWAY & SPEED',
      'velocity': 'Daily Spend Rate',
      'runway': 'Runway Forecast',
      'days_left': 'days left',
      'infinite': 'Infinite',
      'cancel': 'Cancel',
      'add': 'Add',
      'clear_all': 'Clear All',
      'reset_warning': 'This will permanently delete all salary configurations, fixed bills, and transactions. This action cannot be undone.',
      'reset_confirm': 'Reset All Data?',
      'food': 'Food & Groceries',
      'transport': 'Transportation',
      'rent': 'Rent & Housing',
      'entertainment': 'Entertainment',
      'shopping': 'Shopping & Clothes',
      'utilities': 'Utilities',
      'health_excellent': 'Excellent! Highly disciplined.',
      'health_good': 'Good budget balance.',
      'health_fair': 'Fair. Watch daily spend.',
      'health_poor': 'Poor. Try increasing savings.',
      'copy_csv': 'Copy CSV Report',
      'copied': 'CSV Report copied to clipboard!',
      
      // New Table Builder keys
      'reason': 'Reason / Description',
      'excel_wizard': 'Excel Table Builder',
      'select_cols': 'Select Columns to Export',
      'date_range': 'Filter Date Range',
      'all_time': 'All Time',
      'this_week': 'This Week',
      'this_month': 'This Month',
      'generate_excel': 'Generate & Copy Excel Table',
      'custom_range': 'Custom Date Range',

      // Advanced Keys
      'scope': 'Scope',
      'payment_method': 'Payment Method',
      'contact': 'Contact / Name',
      'personal': 'Personal / Daily',
      'business': 'Business',
      'all_scopes': 'All (Combined)',
      'cash': 'Cash',
      'card': 'Card / POS',
      'transfer': 'Bank Transfer',
      'debt': 'Debt / Credit',
      'daily_earnings': 'Daily Earnings',
      'log_daily_earnings': "Log Day's Earnings",
      'daily_earnings_desc': 'Enter total money received today in one click',
      'usd_received': 'USD (\$) Received Today',
      'iqd_received': 'IQD (د.ع) Received Today',
      'notes': 'Notes / Context',
      'daily_sales_notes': 'Shop daily sales and revenues',
      'budget_mode': 'Daily Budget Mode',
      'auto_budget': 'Auto-Calculate from Monthly Income',
      'manual_budget': 'Set Manual Budget Per Day',
      'personal_daily_budget': 'Personal Daily Budget',
      'business_daily_budget': 'Business Daily Budget',
      'configure_personal': 'Configure Personal Wallet',
      'configure_business': 'Configure Business Wallet',
      
      // Category Keys
      'dining': 'Dining Out',
      'medical': 'Healthcare & Medical',
      'education': 'Education',
      'gift': 'Gifts & Charity',
      'freelance': 'Freelance / Side Hustle',
      'investments': 'Investments',
      'inventory': 'Inventory / Stock',
      'marketing': 'Marketing & Ads',
      'salaries': 'Staff Salaries',
      'software': 'Software & Tools',
      'logistics': 'Logistics & Shipping',
      'taxes': 'Taxes & Fees',
      'office_supplies': 'Office Supplies',
      'sales_revenue': 'Sales & Revenues',
      'service_consulting': 'Service & Consulting',
      'capital': 'Capital Deposit',
      'refund': 'Refunds',
      'business_income_lbl': 'Monthly Target Revenue',
      'business_savings_lbl': 'Monthly Profit Target',
      
      // AI Studio Keys
      'ai_studio': 'AI Studio',
      'ai_chat': 'AI Financial Chat',
      'ai_image': 'AI Image Generator',
      'ai_video': 'AI Video Studio',
      'ai_audio': 'Kurdish AI Dialogue',
      'gemini_key_lbl': 'Gemini API Key (Google AI Studio)',
      'gemini_key_hint': 'Paste API Key for unlimited free live chat...',
      'enter_key_warning': 'Please set your Gemini API key in Settings or AI Chat to get live responses.',
      'generate': 'Generate',
      'prompt': 'Describe what you want to create...',
      'generating': 'Generating assets via AI...',
      'video_prompt_lbl': 'Video Scene Description',
      'image_prompt_lbl': 'Image Art Prompt',
      'podcast_speakers': 'Select Characters',
      'podcast_topic': 'Select Debate Topic',
      'generate_podcast': 'Start AI Conversation',
      'podcast_playing': 'Playing AI Debate...',
      'podcast_paused': 'AI Debate Paused',
      'staff_payroll': 'Staff Payroll',
      'staff_payroll_desc': 'Log daily worker salaries & check sheets',
      'staff_list': 'Staff List',
      'add_staff': 'Add Staff Member',
      'staff_name': 'Staff Name',
      'role': 'Role',
      'base_salary': 'Base Daily Salary',
      'actions': 'Actions',
      'daily_log': 'Daily Work Log',
      'present': 'Present',
      'half_day': 'Half Day',
      'absent': 'Absent',
      'custom': 'Custom',
      'commit_payroll': 'Commit Daily Payroll',
      'payroll_submitted': 'Daily payroll committed and logged to expenses!',
      'payroll_date': 'Payroll Date',
      'widget_simulator': 'iOS Widget Simulator',
      'widget_simulator_desc': 'Configure and preview iPhone quick actions',
      'widget_setup_guide': 'How to set up on iPhone Home Screen',
      'save_widget_presets': 'Save Widget Presets',
      'widget_presets_saved': 'Widget presets saved successfully!',
      'invalid_numbers': 'Please enter valid numbers!',
    },
    'ku': {
      'app_title': 'سەلاريفلۆو',
      'welcome_back': 'بەخێربێیتەوە',
      'manager_title': 'بەڕێوەبەری دارایی',
      'remaining_budget': 'بودجەی ماوە',
      'exceeded_by': 'تێپەڕاندنی خەرجی بە',
      'allowance': 'خەرجی ڕۆژانە',
      'todays_spent': 'خەرجکراوی ئەمڕۆ',
      'todays_income': 'داهاتی ئەمڕۆ',
      'quick_log': 'تۆمارکردنی خێرای خەرجی',
      'recent_transactions': 'دوایین مامەڵەکان',
      'see_all': 'بینینی هەمووی',
      'no_transactions': 'هیچ مامەڵەیەک تۆمار نەکراوە',
      'tap_add': 'داگرە لەسەر دوگمەی + بۆ زیادکردن',
      'new_transaction': 'مامەڵەی نوێ',
      'title': 'ناونیشان',
      'amount': 'بڕ',
      'category': 'پۆلێن',
      'date': 'ڕێکەوت',
      'add_transaction': 'زیادکردنی مامەڵە',
      'expense': 'خەرجی',
      'income': 'داهات',
      'salary': 'مووچە',
      'other': 'هیتر',
      'analysis': 'شیکاری',
      'settings': 'ڕێکخستنەکان',
      'net_salary': 'مووچە / داهاتی مانگانەی پاکت',
      'savings_target': 'ئامانجی پاشەکەوت / قازانجی مانگانە',
      'save_settings': 'ڕێکخستنەکان بپارێزە',
      'fixed_bills': 'کرێ و پسوولەی مانگانە',
      'no_bills': 'هیچ پسوولەیەکی مانگانە دیاری نەکراوە',
      'add_bill': 'زیادکردنی پسوولەی جێگیر',
      'bill_name': 'ناوی پسوولە (بۆ نموونە: کرێ، ئینتەرنێت)',
      'system_data': 'داتای سیستم',
      'reset_app': 'سڕینەوەی هەموو داتاکانی بەرنامە',
      'language': 'زمان',
      'currency': 'دراو',
      'financial_health': 'تەندروستی دارایی',
      'health_score': 'نمرەی تەندروستی دارایی',
      'burn_rate': 'ڕێژەی بەکارهێنانی داهات',
      'spending_breakdown': 'دابەشبوونی خەرجییەکان',
      'no_expense_data': 'هیچ داتایەکی خەرجی نییە بۆ شیکردنەوە',
      'cash_flow': 'ڕەوتی دارایی مانگانە',
      'flow_income': 'کۆی داهات',
      'flow_spend': 'کۆی خەرجی',
      'flow_savings': 'پاشەکەوتی پاکت',
      'runway_card': 'خێرایی و کاتی مانەوە',
      'velocity': 'خێرایی خەرجکردنی ڕۆژانە',
      'runway': 'کاتی مانەوەی داهات',
      'days_left': 'ڕۆژ ماوە',
      'infinite': 'بێکۆتایی',
      'cancel': 'پاشگەزبوونەوە',
      'add': 'زیادکردن',
      'clear_all': 'سڕینەوەی گشتی',
      'reset_warning': 'ئەمە هەموو ڕێکخستنەکانی مووچە، پسوولە جێگیرەکان، و مامەڵەکان دەسڕێتەوە بە یەکجاری و ناگەڕێتەوە.',
      'reset_confirm': 'سڕینەوەی هەموو داتاکان؟',
      'food': 'خۆراک و سەوزەوات',
      'transport': 'گواستنەوە و بەنزین',
      'rent': 'کرێی خانوو / نووسینگە',
      'entertainment': 'کات بەسەربردن',
      'shopping': 'جلوبەرگ و بازاڕکردن',
      'utilities': 'پسوولە و خزمەتگوزاری',
      'health_excellent': 'ناوازەیە! زۆر بە دیسیپلینیت.',
      'health_good': 'تەندروستی دارایی باشە.',
      'health_fair': 'مامناوەندە، وریای خەرجی ڕۆژانە بە.',
      'health_poor': 'لاوازە، هەوڵبدە پاشەکەوت زیاد بکەیت.',
      'copy_csv': 'کۆپیکردنی ڕاپۆرتی CSV',
      'copied': 'ڕاپۆرتی CSV کۆپیکرا بۆ حافیزەی مۆبایلەکە!',
      
      // Kurdish Table Builder keys
      'reason': 'هۆکار / بۆچی خەرجکرا',
      'excel_wizard': 'خشتەسازی ئێکسڵ',
      'select_cols': 'دیاریکردنی ستوونەکانی ڕاپۆرت',
      'date_range': 'فلتەرکردنی ماوەی ڕێکەوت',
      'all_time': 'هەموو کاتێک',
      'this_week': 'ئەم هەفتەیە',
      'this_month': 'ئەم مانگە',
      'generate_excel': 'دروستکردن و کۆپیکردنی خشتەکە',
      'custom_range': 'دیاریکردنی ماوەی تایبەت',

      // Advanced Keys Kurdish
      'scope': 'جۆری دارایی',
      'payment_method': 'شێوازی دان',
      'contact': 'ناو / کەسی پەیوەندیدار',
      'personal': 'کەسی / ڕۆژانە',
      'business': 'کار / بازرگانی',
      'all_scopes': 'هەردووکی (تێکەڵاو)',
      'cash': 'نەختینە (کاش)',
      'card': 'کارت / POS',
      'transfer': 'حەواڵەی بانکی',
      'debt': 'قەرز / متمانە',
      'daily_earnings': 'داهاتی ڕۆژانە',
      'log_daily_earnings': 'تۆمارکردنی داهاتی ئەمڕۆ',
      'daily_earnings_desc': 'تۆمارکردنی کۆی پارەی هاتوو بە یەک کلیک',
      'usd_received': 'کۆی دۆلاری وەرگیراو (\$)',
      'iqd_received': 'کۆی دیناری وەرگیراو (د.ع)',
      'notes': 'تێبینی / سەرنج',
      'daily_sales_notes': 'داهات و فرۆشی ڕۆژانەی دوکان/کۆمپانیا',
      'budget_mode': 'شێوازی بودجەی ڕۆژانە',
      'auto_budget': 'ئۆتۆماتیکی لەسەر بنەمای داهاتی مانگانە',
      'manual_budget': 'دەستنیشانکردنی دەستی ڕۆژانە',
      'personal_daily_budget': 'بودجەی ڕۆژانەی کەسی',
      'business_daily_budget': 'بودجەی ڕۆژانەی بازرگانی',
      'configure_personal': 'ڕێکخستنی جزدانی کەسی',
      'configure_business': 'ڕێکخستنی جزدانی بازرگانی',

      // Category Keys Kurdish
      'dining': 'چێشتخانە و کافتەریا',
      'medical': 'تەندروستی و دەرمان',
      'education': 'فێربوون و خوێندن',
      'gift': 'بەخشین و دیاری',
      'freelance': 'کاری سەربەخۆ / فریلانسی',
      'investments': 'وەبەرهێنان',
      'inventory': 'کەلوپەل و مەخزەن',
      'marketing': 'ڕیکلام و مارکێتینگ',
      'salaries': 'مووچەی کارمەندان',
      'software': 'سیستم و پرۆگرام',
      'logistics': 'گواستنەوە و پۆست',
      'taxes': 'باج و سەرانە',
      'office_supplies': 'پێداویستی نووسینگە',
      'sales_revenue': 'فرۆشتن و داهاتی کار',
      'service_consulting': 'خزمەتگوزاری و ڕاوێژ',
      'capital': 'سەرمایەگوزاری سەرەکی',
      'refund': 'پارەی گەڕاوە',
      'business_income_lbl': 'داهاتی مانگانەی کار',
      'business_savings_lbl': 'ئامانجی قازانجی مانگانە',
      
      // AI Studio Kurdish Keys
      'ai_studio': 'ستۆدیۆی زیرەکی',
      'ai_chat': 'چاتی دارایی AI',
      'ai_image': 'دروسکردنی وێنە',
      'ai_video': 'دروسکردنی ڤیدیۆ',
      'ai_audio': 'دیبەیتی دەنگی کوردی',
      'gemini_key_lbl': 'کلیلی Gemini API (گووگڵ)',
      'gemini_key_hint': 'لێرە کلیلەکەت بنووسە بۆ بەکارهێنانی بێسنوور...',
      'enter_key_warning': 'تکایە کلیلی Gemini API داخڵ بکە لە ڕێکخستنەکان یان لێرە بۆ وەڵامی ڕاستەوخۆ.',
      'generate': 'دروستکردن',
      'prompt': 'وەسفی کارەکە بکە لێرەدا...',
      'generating': 'ژیری دەستکرد خەریکی کارە...',
      'video_prompt_lbl': 'وەسفی دیمەنی ڤیدیۆیی',
      'image_prompt_lbl': 'وەسفی بابەت بۆ وێنەکە',
      'podcast_speakers': 'دیاریکردنی کەسایەتییەکان',
      'podcast_topic': 'دیاریکردنی بابەتی گفتوگۆ',
      'generate_podcast': 'دەستپێکردنی گفتوگۆی ژیری',
      'podcast_playing': 'گفتوگۆکە پەخش دەبێت...',
      'podcast_paused': 'گفتوگۆکە ڕاگیرا',
      'staff_payroll': 'مووچەی کارمەندان',
      'staff_payroll_desc': 'تۆمارکردنی مووچەی ڕۆژانەی کارمەندان و شیتەکان',
      'staff_list': 'لیستی کارمەندان',
      'add_staff': 'زیادکردنی کارمەند',
      'staff_name': 'ناوی کارمەند',
      'role': 'ڕۆڵ / کارەکەی',
      'base_salary': 'مووچەی بنەڕەتی ڕۆژانە',
      'actions': 'کردارەکان',
      'daily_log': 'تۆماری ڕۆژانەی کار',
      'present': 'ئامادە (تەواو)',
      'half_day': 'نیوە ڕۆژ',
      'absent': 'نەهاتوو (سفر)',
      'custom': 'دیاریکراو',
      'commit_payroll': 'تۆمارکردنی مووچەی ڕۆژەکە',
      'payroll_submitted': 'مووچەی ڕۆژانەی کارمەندان تۆمارکرا لە خەرجییەکان!',
      'payroll_date': 'ڕێکەوتی مووچە',
      'widget_simulator': 'هاوشێوەکەری وێجێتی iOS',
      'widget_simulator_desc': 'ڕێکخستن و پێشبینیکردنی وێجێتی ئایفۆن',
      'widget_setup_guide': 'چۆنیەتی دانان لەسەر شاشەی سەرەکی ئایفۆن',
      'save_widget_presets': 'پاشەکەوتکردنی بڕەکانی وێجێت',
      'widget_presets_saved': 'بڕە خێراکانی وێجێت بە سەرکەوتوویی پاشەکەوتکران!',
      'invalid_numbers': 'تکایە ژمارەی دروست داخڵ بکە!',
    }
  };
}
