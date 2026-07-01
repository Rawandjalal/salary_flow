import 'dart:convert';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final bool isIncome;
  final String category;
  final DateTime date;
  final String description;
  final String currency; // 'USD' or 'IQD'

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.date,
    this.description = '',
    this.currency = 'USD', // Default to USD for old stored items compatibility
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'isIncome': isIncome,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'currency': currency,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      isIncome: map['isIncome'] ?? false,
      category: map['category'] ?? 'Other',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      description: map['description'] ?? '',
      currency: map['currency'] ?? 'USD', // Default to USD if missing
    );
  }

  String toJson() => json.encode(toMap());

  factory Transaction.fromJson(String source) => Transaction.fromMap(json.decode(source));
}
