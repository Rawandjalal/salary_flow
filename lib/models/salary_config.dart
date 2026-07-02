import 'dart:convert';

class SalaryConfig {
  // Personal configs
  final double monthlySalaryUSD;
  final double monthlySalaryIQD;
  final double savingsGoalUSD;
  final double savingsGoalIQD;
  final Map<String, double> fixedExpensesUSD;
  final Map<String, double> fixedExpensesIQD;

  // Business configs
  final double businessIncomeUSD;
  final double businessIncomeIQD;
  final double businessSavingsGoalUSD;
  final double businessSavingsGoalIQD;
  final Map<String, double> businessFixedExpensesUSD;
  final Map<String, double> businessFixedExpensesIQD;

  // Budget settings
  final bool useManualDailyBudget;
  final double personalDailyBudgetUSD;
  final double personalDailyBudgetIQD;
  final double businessDailyBudgetUSD;
  final double businessDailyBudgetIQD;

  final String language;

  SalaryConfig({
    this.monthlySalaryUSD = 0.0,
    this.monthlySalaryIQD = 0.0,
    this.savingsGoalUSD = 0.0,
    this.savingsGoalIQD = 0.0,
    this.fixedExpensesUSD = const {},
    this.fixedExpensesIQD = const {},
    this.businessIncomeUSD = 0.0,
    this.businessIncomeIQD = 0.0,
    this.businessSavingsGoalUSD = 0.0,
    this.businessSavingsGoalIQD = 0.0,
    this.businessFixedExpensesUSD = const {},
    this.businessFixedExpensesIQD = const {},
    this.useManualDailyBudget = false,
    this.personalDailyBudgetUSD = 0.0,
    this.personalDailyBudgetIQD = 0.0,
    this.businessDailyBudgetUSD = 0.0,
    this.businessDailyBudgetIQD = 0.0,
    this.language = 'en',
  });

  double get totalFixedExpensesUSD {
    return fixedExpensesUSD.values.fold(0.0, (sum, val) => sum + val);
  }

  double get totalFixedExpensesIQD {
    return fixedExpensesIQD.values.fold(0.0, (sum, val) => sum + val);
  }

  double get totalBusinessFixedExpensesUSD {
    return businessFixedExpensesUSD.values.fold(0.0, (sum, val) => sum + val);
  }

  double get totalBusinessFixedExpensesIQD {
    return businessFixedExpensesIQD.values.fold(0.0, (sum, val) => sum + val);
  }

  double get netDisposableIncomeUSD {
    return monthlySalaryUSD - savingsGoalUSD - totalFixedExpensesUSD;
  }

  double get netDisposableIncomeIQD {
    return monthlySalaryIQD - savingsGoalIQD - totalFixedExpensesIQD;
  }

  double get netBusinessDisposableIncomeUSD {
    return businessIncomeUSD - businessSavingsGoalUSD - totalBusinessFixedExpensesUSD;
  }

  double get netBusinessDisposableIncomeIQD {
    return businessIncomeIQD - businessSavingsGoalIQD - totalBusinessFixedExpensesIQD;
  }

  SalaryConfig copyWith({
    double? monthlySalaryUSD,
    double? monthlySalaryIQD,
    double? savingsGoalUSD,
    double? savingsGoalIQD,
    Map<String, double>? fixedExpensesUSD,
    Map<String, double>? fixedExpensesIQD,
    double? businessIncomeUSD,
    double? businessIncomeIQD,
    double? businessSavingsGoalUSD,
    double? businessSavingsGoalIQD,
    Map<String, double>? businessFixedExpensesUSD,
    Map<String, double>? businessFixedExpensesIQD,
    bool? useManualDailyBudget,
    double? personalDailyBudgetUSD,
    double? personalDailyBudgetIQD,
    double? businessDailyBudgetUSD,
    double? businessDailyBudgetIQD,
    String? language,
  }) {
    return SalaryConfig(
      monthlySalaryUSD: monthlySalaryUSD ?? this.monthlySalaryUSD,
      monthlySalaryIQD: monthlySalaryIQD ?? this.monthlySalaryIQD,
      savingsGoalUSD: savingsGoalUSD ?? this.savingsGoalUSD,
      savingsGoalIQD: savingsGoalIQD ?? this.savingsGoalIQD,
      fixedExpensesUSD: fixedExpensesUSD ?? this.fixedExpensesUSD,
      fixedExpensesIQD: fixedExpensesIQD ?? this.fixedExpensesIQD,
      businessIncomeUSD: businessIncomeUSD ?? this.businessIncomeUSD,
      businessIncomeIQD: businessIncomeIQD ?? this.businessIncomeIQD,
      businessSavingsGoalUSD: businessSavingsGoalUSD ?? this.businessSavingsGoalUSD,
      businessSavingsGoalIQD: businessSavingsGoalIQD ?? this.businessSavingsGoalIQD,
      businessFixedExpensesUSD: businessFixedExpensesUSD ?? this.businessFixedExpensesUSD,
      businessFixedExpensesIQD: businessFixedExpensesIQD ?? this.businessFixedExpensesIQD,
      useManualDailyBudget: useManualDailyBudget ?? this.useManualDailyBudget,
      personalDailyBudgetUSD: personalDailyBudgetUSD ?? this.personalDailyBudgetUSD,
      personalDailyBudgetIQD: personalDailyBudgetIQD ?? this.personalDailyBudgetIQD,
      businessDailyBudgetUSD: businessDailyBudgetUSD ?? this.businessDailyBudgetUSD,
      businessDailyBudgetIQD: businessDailyBudgetIQD ?? this.businessDailyBudgetIQD,
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
      'businessIncomeUSD': businessIncomeUSD,
      'businessIncomeIQD': businessIncomeIQD,
      'businessSavingsGoalUSD': businessSavingsGoalUSD,
      'businessSavingsGoalIQD': businessSavingsGoalIQD,
      'businessFixedExpensesUSD': businessFixedExpensesUSD,
      'businessFixedExpensesIQD': businessFixedExpensesIQD,
      'useManualDailyBudget': useManualDailyBudget,
      'personalDailyBudgetUSD': personalDailyBudgetUSD,
      'personalDailyBudgetIQD': personalDailyBudgetIQD,
      'businessDailyBudgetUSD': businessDailyBudgetUSD,
      'businessDailyBudgetIQD': businessDailyBudgetIQD,
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

    // Business fixed expenses parsing
    Map<String, double> businessExpUSD = {};
    if (map['businessFixedExpensesUSD'] != null) {
      businessExpUSD = (map['businessFixedExpensesUSD'] as Map).map(
        (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
      );
    }

    Map<String, double> businessExpIQD = {};
    if (map['businessFixedExpensesIQD'] != null) {
      businessExpIQD = (map['businessFixedExpensesIQD'] as Map).map(
        (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
      );
    }

    return SalaryConfig(
      monthlySalaryUSD: initialSalaryUSD,
      monthlySalaryIQD: initialSalaryIQD,
      savingsGoalUSD: initialGoalUSD,
      savingsGoalIQD: initialGoalIQD,
      fixedExpensesUSD: initialExpensesUSD,
      fixedExpensesIQD: initialExpensesIQD,
      businessIncomeUSD: (map['businessIncomeUSD'] as num?)?.toDouble() ?? 0.0,
      businessIncomeIQD: (map['businessIncomeIQD'] as num?)?.toDouble() ?? 0.0,
      businessSavingsGoalUSD: (map['businessSavingsGoalUSD'] as num?)?.toDouble() ?? 0.0,
      businessSavingsGoalIQD: (map['businessSavingsGoalIQD'] as num?)?.toDouble() ?? 0.0,
      businessFixedExpensesUSD: businessExpUSD,
      businessFixedExpensesIQD: businessExpIQD,
      useManualDailyBudget: map['useManualDailyBudget'] ?? false,
      personalDailyBudgetUSD: (map['personalDailyBudgetUSD'] as num?)?.toDouble() ?? 0.0,
      personalDailyBudgetIQD: (map['personalDailyBudgetIQD'] as num?)?.toDouble() ?? 0.0,
      businessDailyBudgetUSD: (map['businessDailyBudgetUSD'] as num?)?.toDouble() ?? 0.0,
      businessDailyBudgetIQD: (map['businessDailyBudgetIQD'] as num?)?.toDouble() ?? 0.0,
      language: map['language'] ?? 'en',
    );
  }

  String toJson() => json.encode(toMap());

  factory SalaryConfig.fromJson(String source) => SalaryConfig.fromMap(json.decode(source));
}
