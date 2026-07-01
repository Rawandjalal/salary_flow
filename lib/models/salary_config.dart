import 'dart:convert';

class SalaryConfig {
  final double monthlySalaryUSD;
  final double monthlySalaryIQD;
  final double savingsGoalUSD;
  final double savingsGoalIQD;
  final Map<String, double> fixedExpensesUSD;
  final Map<String, double> fixedExpensesIQD;
  final String language;

  SalaryConfig({
    this.monthlySalaryUSD = 0.0,
    this.monthlySalaryIQD = 0.0,
    this.savingsGoalUSD = 0.0,
    this.savingsGoalIQD = 0.0,
    this.fixedExpensesUSD = const {},
    this.fixedExpensesIQD = const {},
    this.language = 'en',
  });

  double get totalFixedExpensesUSD {
    return fixedExpensesUSD.values.fold(0.0, (sum, val) => sum + val);
  }

  double get totalFixedExpensesIQD {
    return fixedExpensesIQD.values.fold(0.0, (sum, val) => sum + val);
  }

  double get netDisposableIncomeUSD {
    return monthlySalaryUSD - savingsGoalUSD - totalFixedExpensesUSD;
  }

  double get netDisposableIncomeIQD {
    return monthlySalaryIQD - savingsGoalIQD - totalFixedExpensesIQD;
  }

  SalaryConfig copyWith({
    double? monthlySalaryUSD,
    double? monthlySalaryIQD,
    double? savingsGoalUSD,
    double? savingsGoalIQD,
    Map<String, double>? fixedExpensesUSD,
    Map<String, double>? fixedExpensesIQD,
    String? language,
  }) {
    return SalaryConfig(
      monthlySalaryUSD: monthlySalaryUSD ?? this.monthlySalaryUSD,
      monthlySalaryIQD: monthlySalaryIQD ?? this.monthlySalaryIQD,
      savingsGoalUSD: savingsGoalUSD ?? this.savingsGoalUSD,
      savingsGoalIQD: savingsGoalIQD ?? this.savingsGoalIQD,
      fixedExpensesUSD: fixedExpensesUSD ?? this.fixedExpensesUSD,
      fixedExpensesIQD: fixedExpensesIQD ?? this.fixedExpensesIQD,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'monthlySalaryUSD': monthlySalaryUSD,
      'monthlySalaryIQD': monthlySalaryIQD,
      'savingsGoalUSD': savingsGoalUSD,
      'savingsGoalIQD': savingsGoalIQD,
      'fixedExpensesUSD': fixedExpensesUSD,
      'fixedExpensesIQD': fixedExpensesIQD,
      'language': language,
    };
  }

  factory SalaryConfig.fromMap(Map<String, dynamic> map) {
    // Migration Logic: Safely converts old single-currency configurations
    final oldSalary = (map['monthlySalary'] as num?)?.toDouble() ?? 0.0;
    final oldGoal = (map['savingsGoal'] as num?)?.toDouble() ?? 0.0;
    final oldCurrency = map['currency'] as String? ?? 'USD';

    final initialSalaryUSD = map['monthlySalaryUSD'] != null
        ? (map['monthlySalaryUSD'] as num).toDouble()
        : (oldCurrency == 'USD' ? oldSalary : 0.0);

    final initialSalaryIQD = map['monthlySalaryIQD'] != null
        ? (map['monthlySalaryIQD'] as num).toDouble()
        : (oldCurrency == 'IQD' ? oldSalary : 0.0);

    final initialGoalUSD = map['savingsGoalUSD'] != null
        ? (map['savingsGoalUSD'] as num).toDouble()
        : (oldCurrency == 'USD' ? oldGoal : 0.0);

    final initialGoalIQD = map['savingsGoalIQD'] != null
        ? (map['savingsGoalIQD'] as num).toDouble()
        : (oldCurrency == 'IQD' ? oldGoal : 0.0);

    Map<String, double> oldExpenses = {};
    if (map['fixedExpenses'] != null) {
      oldExpenses = (map['fixedExpenses'] as Map).map(
        (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
      );
    }

    Map<String, double> initialExpensesUSD = {};
    if (map['fixedExpensesUSD'] != null) {
      initialExpensesUSD = (map['fixedExpensesUSD'] as Map).map(
        (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
      );
    } else {
      initialExpensesUSD = oldCurrency == 'USD' ? oldExpenses : {};
    }

    Map<String, double> initialExpensesIQD = {};
    if (map['fixedExpensesIQD'] != null) {
      initialExpensesIQD = (map['fixedExpensesIQD'] as Map).map(
        (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
      );
    } else {
      initialExpensesIQD = oldCurrency == 'IQD' ? oldExpenses : {};
    }

    return SalaryConfig(
      monthlySalaryUSD: initialSalaryUSD,
      monthlySalaryIQD: initialSalaryIQD,
      savingsGoalUSD: initialGoalUSD,
      savingsGoalIQD: initialGoalIQD,
      fixedExpensesUSD: initialExpensesUSD,
      fixedExpensesIQD: initialExpensesIQD,
      language: map['language'] ?? 'en',
    );
  }

  String toJson() => json.encode(toMap());

  factory SalaryConfig.fromJson(String source) => SalaryConfig.fromMap(json.decode(source));
}
