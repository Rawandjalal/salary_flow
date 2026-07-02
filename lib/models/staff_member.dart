import 'dart:convert';

class StaffMember {
  final String id;
  final String name;
  final String role;
  final double baseSalary;
  final String currency; // 'USD' or 'IQD'

  StaffMember({
    required this.id,
    required this.name,
    required this.role,
    required this.baseSalary,
    required this.currency,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'baseSalary': baseSalary,
      'currency': currency,
    };
  }

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      baseSalary: (json['baseSalary'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }
}

class PayrollRecord {
  final String id;
  final String staffId;
  final String staffName;
  final DateTime date;
  final double amount;
  final String status; // 'present', 'half', 'absent', 'custom'
  final String currency;

  PayrollRecord({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.date,
    required this.amount,
    required this.status,
    required this.currency,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffId': staffId,
      'staffName': staffName,
      'date': date.toIso8601String(),
      'amount': amount,
      'status': status,
      'currency': currency,
    };
  }

  factory PayrollRecord.fromJson(Map<String, dynamic> json) {
    return PayrollRecord(
      id: json['id'] as String,
      staffId: json['staffId'] as String,
      staffName: json['staffName'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      currency: json['currency'] as String,
    );
  }
}
