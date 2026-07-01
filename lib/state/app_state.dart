import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/salary_config.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storageService;

  List<Transaction> _transactions = [];
  SalaryConfig _salaryConfig = SalaryConfig();
  bool _isLoading = true;

  AppState(this._storageService) {
    _loadFromStorage();
  }

  bool get isLoading => _isLoading;
  List<Transaction> get transactions => _transactions;
  SalaryConfig get salaryConfig => _salaryConfig;

  // Language Preference
  bool get isRtl => _salaryConfig.language == 'ku';

  void _loadFromStorage() {
    _transactions = _storageService.getTransactions();
    _salaryConfig = _storageService.getSalaryConfig();
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

  Future<void> clearAllData() async {
    _transactions.clear();
    _salaryConfig = SalaryConfig();
    await _storageService.clearAll();
    notifyListeners();
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

  // 1. Daily Allowance
  double get dailyAllowanceUSD {
    final disposable = _salaryConfig.netDisposableIncomeUSD;
    if (disposable <= 0) return 0.0;
    return disposable / daysInMonth;
  }

  double get dailyAllowanceIQD {
    final disposable = _salaryConfig.netDisposableIncomeIQD;
    if (disposable <= 0) return 0.0;
    return disposable / daysInMonth;
  }

  // 2. Today's Expenses
  double get todaysExpensesUSD {
    return _transactions
        .where((tx) => !tx.isIncome && tx.currency == 'USD' && _isToday(tx.date))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get todaysExpensesIQD {
    return _transactions
        .where((tx) => !tx.isIncome && tx.currency == 'IQD' && _isToday(tx.date))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // 3. Today's Income
  double get todaysIncomeUSD {
    return _transactions
        .where((tx) => tx.isIncome && tx.currency == 'USD' && _isToday(tx.date))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get todaysIncomeIQD {
    return _transactions
        .where((tx) => tx.isIncome && tx.currency == 'IQD' && _isToday(tx.date))
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
        .where((tx) => !tx.isIncome && tx.currency == 'USD' && _isThisMonth(tx.date))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get monthlyExpensesSoFarIQD {
    return _transactions
        .where((tx) => !tx.isIncome && tx.currency == 'IQD' && _isThisMonth(tx.date))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // 7. Monthly Additional Income
  double get monthlyAdditionalIncomeUSD {
    return _transactions
        .where((tx) => tx.isIncome && tx.currency == 'USD' && _isThisMonth(tx.date))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get monthlyAdditionalIncomeIQD {
    return _transactions
        .where((tx) => tx.isIncome && tx.currency == 'IQD' && _isThisMonth(tx.date))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // 8. Total Monthly Expenses (So Far + Fixed Bills)
  double get totalMonthlyExpensesUSD {
    return monthlyExpensesSoFarUSD + _salaryConfig.totalFixedExpensesUSD;
  }

  double get totalMonthlyExpensesIQD {
    return monthlyExpensesSoFarIQD + _salaryConfig.totalFixedExpensesIQD;
  }

  // 9. Total Monthly Income (Salary + Additional Incomes)
  double get totalMonthlyIncomeUSD {
    return _salaryConfig.monthlySalaryUSD + monthlyAdditionalIncomeUSD;
  }

  double get totalMonthlyIncomeIQD {
    return _salaryConfig.monthlySalaryIQD + monthlyAdditionalIncomeIQD;
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

  // 13. Runway Forecast (how many days funds will last at current velocity)
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

    final fixedRatio = _salaryConfig.totalFixedExpensesUSD / income;
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

    final fixedRatio = _salaryConfig.totalFixedExpensesIQD / income;
    final fixedScore = (1.0 - (fixedRatio / 0.60)).clamp(0.0, 1.0) * 30;

    final dailyRatio = todaysExpensesIQD / (dailyAllowanceIQD > 0 ? dailyAllowanceIQD : 1.0);
    final disciplineScore = (2.0 - dailyRatio).clamp(0.0, 2.0) / 2.0 * 30;

    return (savingsScore + fixedScore + disciplineScore).round();
  }

  // 15. Spend Breakdown by Category
  Map<String, double> getCategoryExpensesBreakdown(String currency) {
    final breakdown = <String, double>{};
    for (var tx in _transactions) {
      if (!tx.isIncome && tx.currency == currency && _isThisMonth(tx.date)) {
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
      return col;
    }).join(',');
    buffer.writeln(headers);

    // Filter List
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
        return '';
      }).join(',');
      buffer.writeln(row);
    }

    return buffer.toString();
  }

  String exportToCsv() {
    return exportCustomCsv(
      selectedColumns: ['Date', 'Title', 'Reason', 'Category', 'Type', 'Amount', 'Currency'],
    );
  }

  // ----------------------------------------------------
  // LOCALIZATION SYSTEM (English & Kurdish Sorani)
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
      'net_salary': 'Net Monthly Salary',
      'savings_target': 'Monthly Savings Target',
      'save_settings': 'Save Salary Settings',
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
      'food': 'Food',
      'transport': 'Transport',
      'rent': 'Rent',
      'entertainment': 'Entertainment',
      'shopping': 'Shopping',
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
      'net_salary': 'مووچەی مانگانەی پاکت',
      'savings_target': 'ئامانجی پاشەکەوتی مانگانە',
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
      'food': 'خۆراک',
      'transport': 'گواستنەوە',
      'rent': 'کرێی خانوو',
      'entertainment': 'کات بەسەربردن',
      'shopping': 'بازاڕکردن',
      'utilities': 'خزمەتگوزارییەکان',
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
    }
  };
}
