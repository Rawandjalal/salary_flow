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
  final String scope; // 'personal' or 'business'
  final String paymentMethod; // 'Cash', 'Card', 'Transfer', 'Debt'
  final String contact; // counterparty or customer name (optional)

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.date,
    this.description = '',
    this.currency = 'USD', // Default to USD for old stored items compatibility
    this.scope = 'personal',
    this.paymentMethod = 'Cash',
    this.contact = '',
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
      'scope': scope,
      'paymentMethod': paymentMethod,
      'contact': contact,
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
      scope: map['scope'] ?? 'personal',
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      contact: map['contact'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Transaction.fromJson(String source) => Transaction.fromMap(json.decode(source));
}
