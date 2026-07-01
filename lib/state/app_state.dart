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

  void _loadFromStorage() {
    _transactions = _storageService.getTransactions();
    _salaryConfig = _storageService.getSalaryConfig();
    _isLoading = false;
    notifyListeners();
  }

  // Load configuration and data from storage
  Future<void> updateSalaryConfig(SalaryConfig config) async {
    _salaryConfig = config;
    await _storageService.saveSalaryConfig(_salaryConfig);
    notifyListeners();
  }

  // Transactions operations
  Future<void> addTransaction(Transaction transaction) async {
    _transactions.insert(0, transaction); // Add to the top
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

  // Helpers for dates
  int get daysInMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0).day;
  }

  int get remainingDaysInMonth {
    final now = DateTime.now();
    return daysInMonth - now.day + 1;
  }

  // Daily Allowance: (Salary - Savings Goal - Fixed Expenses) / Days in Month
  double get dailyAllowance {
    final disposable = _salaryConfig.netDisposableIncome;
    if (disposable <= 0) return 0.0;
    return disposable / daysInMonth;
  }

  // Helper to check if a date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Helper to check if a date is in this month
  bool _isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  // Today's stats
  double get todaysExpenses {
    return _transactions
        .where((tx) => !tx.isIncome && _isToday(tx.date))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get todaysIncome {
    return _transactions
        .where((tx) => tx.isIncome && _isToday(tx.date))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get remainingDailyBudget {
    final budget = dailyAllowance + todaysIncome - todaysExpenses;
    return budget;
  }

  double get budgetUsageRatio {
    final allowance = dailyAllowance + todaysIncome;
    if (allowance <= 0) return 1.0;
    final ratio = todaysExpenses / allowance;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  // Monthly stats
  double get monthlyExpensesSoFar {
    return _transactions
        .where((tx) => !tx.isIncome && _isThisMonth(tx.date))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get monthlyAdditionalIncome {
    return _transactions
        .where((tx) => tx.isIncome && _isThisMonth(tx.date))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalMonthlyExpenses {
    return monthlyExpensesSoFar + _salaryConfig.totalFixedExpenses;
  }

  double get totalMonthlyIncome {
    return _salaryConfig.monthlySalary + monthlyAdditionalIncome;
  }

  double get monthlySavingsRealized {
    final net = totalMonthlyIncome - totalMonthlyExpenses;
    return net > 0 ? net : 0.0;
  }

  // Filtering transactions
  List<Transaction> get todaysTransactions {
    return _transactions.where((tx) => _isToday(tx.date)).toList();
  }

  List<Transaction> get thisMonthsTransactions {
    return _transactions.where((tx) => _isThisMonth(tx.date)).toList();
  }

  // Analytics helper: Spend by Category
  Map<String, double> get categoryExpensesBreakdown {
    final breakdown = <String, double>{};
    for (var tx in _transactions) {
      if (!tx.isIncome && _isThisMonth(tx.date)) {
        breakdown[tx.category] = (breakdown[tx.category] ?? 0.0) + tx.amount;
      }
    }
    return breakdown;
  }
}
