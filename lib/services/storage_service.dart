import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/salary_config.dart';

class StorageService {
  static const String _keyTransactions = 'transactions';
  static const String _keySalaryConfig = 'salary_config';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Transactions
  List<Transaction> getTransactions() {
    final list = _prefs.getStringList(_keyTransactions);
    if (list == null) return [];
    try {
      return list.map((item) => Transaction.fromJson(item)).toList();
    } catch (e) {
      // Fallback in case of parse error
      return [];
    }
  }

  Future<void> saveTransactions(List<Transaction> transactions) async {
    final list = transactions.map((item) => item.toJson()).toList();
    await _prefs.setStringList(_keyTransactions, list);
  }

  // Salary Configuration
  SalaryConfig getSalaryConfig() {
    final data = _prefs.getString(_keySalaryConfig);
    if (data == null) return SalaryConfig();
    try {
      return SalaryConfig.fromJson(data);
    } catch (e) {
      return SalaryConfig();
    }
  }

  Future<void> saveSalaryConfig(SalaryConfig config) async {
    await _prefs.setString(_keySalaryConfig, config.toJson());
  }

  // Generic String Getters & Setters
  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  // Clear data
  Future<void> clearAll() async {
    await _prefs.remove(_keyTransactions);
    await _prefs.remove(_keySalaryConfig);
  }
}
