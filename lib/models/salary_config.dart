import 'dart:convert';

class SalaryConfig {
  final double monthlySalary;
  final int payDay; // e.g. 1st, 25th of the month
  final double savingsGoal; // amount to save each month
  final Map<String, double> fixedExpenses; // e.g. {'Rent': 1200.0, 'Utilities': 150.0}

  SalaryConfig({
    this.monthlySalary = 0.0,
    this.payDay = 1,
    this.savingsGoal = 0.0,
    this.fixedExpenses = const {},
  });

  double get totalFixedExpenses {
    return fixedExpenses.values.fold(0.0, (sum, val) => sum + val);
  }

  double get netDisposableIncome {
    final disposable = monthlySalary - savingsGoal - totalFixedExpenses;
    return disposable > 0 ? disposable : 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'monthlySalary': monthlySalary,
      'payDay': payDay,
      'savingsGoal': savingsGoal,
      'fixedExpenses': fixedExpenses,
    };
  }

  factory SalaryConfig.fromMap(Map<String, dynamic> map) {
    return SalaryConfig(
      monthlySalary: (map['monthlySalary'] as num?)?.toDouble() ?? 0.0,
      payDay: map['payDay'] as int? ?? 1,
      savingsGoal: (map['savingsGoal'] as num?)?.toDouble() ?? 0.0,
      fixedExpenses: Map<String, double>.from(
        (map['fixedExpenses'] as Map?)?.map(
          (k, v) => MapEntry(k as String, (v as num).toDouble()),
        ) ?? {},
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory SalaryConfig.fromJson(String source) => SalaryConfig.fromMap(json.decode(source));

  SalaryConfig copyWith({
    double? monthlySalary,
    int? payDay,
    double? savingsGoal,
    Map<String, double>? fixedExpenses,
  }) {
    return SalaryConfig(
      monthlySalary: monthlySalary ?? this.monthlySalary,
      payDay: payDay ?? this.payDay,
      savingsGoal: savingsGoal ?? this.savingsGoal,
      fixedExpenses: fixedExpenses ?? this.fixedExpenses,
    );
  }
}
