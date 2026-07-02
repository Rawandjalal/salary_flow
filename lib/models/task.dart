import 'dart:convert';

enum TaskCategory {
  shopping,
  food,
  bills,
  savings,
  health,
  entertainment,
  travel,
  other,
}

extension TaskCategoryExtension on TaskCategory {
  String get label {
    switch (this) {
      case TaskCategory.shopping: return 'Shopping';
      case TaskCategory.food:     return 'Food';
      case TaskCategory.bills:    return 'Bills';
      case TaskCategory.savings:  return 'Savings';
      case TaskCategory.health:   return 'Health';
      case TaskCategory.entertainment: return 'Fun';
      case TaskCategory.travel:   return 'Travel';
      case TaskCategory.other:    return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case TaskCategory.shopping:     return '🛍️';
      case TaskCategory.food:         return '🍕';
      case TaskCategory.bills:        return '📄';
      case TaskCategory.savings:      return '💰';
      case TaskCategory.health:       return '🏥';
      case TaskCategory.entertainment: return '🎮';
      case TaskCategory.travel:       return '✈️';
      case TaskCategory.other:        return '📌';
    }
  }
}

class FinancialTask {
  final String id;
  String title;
  String description;
  double? amount;
  DateTime dueDateTime;
  TaskCategory category;
  bool isCompleted;
  final DateTime createdAt;

  FinancialTask({
    required this.id,
    required this.title,
    this.description = '',
    this.amount,
    required this.dueDateTime,
    this.category = TaskCategory.other,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isOverdue =>
      !isCompleted && dueDateTime.isBefore(DateTime.now());

  bool get isDueSoon =>
      !isCompleted &&
      !isOverdue &&
      dueDateTime.difference(DateTime.now()).inMinutes <= 60;

  Duration get timeRemaining =>
      dueDateTime.difference(DateTime.now());

  String get timeRemainingLabel {
    if (isCompleted) return 'Done';
    final diff = dueDateTime.difference(DateTime.now());
    if (diff.isNegative) {
      final abs = diff.abs();
      if (abs.inDays > 0) return '${abs.inDays}d overdue';
      if (abs.inHours > 0) return '${abs.inHours}h overdue';
      return '${abs.inMinutes}m overdue';
    }
    if (diff.inDays > 0) return 'in ${diff.inDays}d ${diff.inHours % 24}h';
    if (diff.inHours > 0) return 'in ${diff.inHours}h ${diff.inMinutes % 60}m';
    if (diff.inMinutes > 0) return 'in ${diff.inMinutes}m';
    return 'Due now!';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'amount': amount,
    'dueDateTime': dueDateTime.toIso8601String(),
    'category': category.index,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
  };

  factory FinancialTask.fromJson(Map<String, dynamic> json) => FinancialTask(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
    dueDateTime: DateTime.parse(json['dueDateTime'] as String),
    category: TaskCategory.values[json['category'] as int? ?? 7],
    isCompleted: json['isCompleted'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  FinancialTask copyWith({
    String? title,
    String? description,
    double? amount,
    DateTime? dueDateTime,
    TaskCategory? category,
    bool? isCompleted,
  }) => FinancialTask(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    amount: amount ?? this.amount,
    dueDateTime: dueDateTime ?? this.dueDateTime,
    category: category ?? this.category,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt,
  );
}
