import 'package:flutter/services.dart';

/// Pushes financial data to the native iOS WidgetKit extension via a
/// MethodChannel. On non-iOS platforms (or when the channel is unavailable)
/// this silently no-ops.
class WidgetDataService {
  WidgetDataService._();

  static const _channel = MethodChannel('com.example.salaryFlow/widget');

  /// Call this whenever balances or budgets change so the home-screen / lock-
  /// screen widget reflects the latest numbers immediately.
  static Future<void> update({
    required double balanceUsd,
    required double balanceIqd,
    required double dailyBudgetUsd,
    required double dailyBudgetIqd,
    required int runwayDays,
    required String lastTransaction,
  }) async {
    try {
      await _channel.invokeMethod<void>('updateWidget', {
        'balance_usd':       balanceUsd,
        'balance_iqd':       balanceIqd,
        'daily_budget_usd':  dailyBudgetUsd,
        'daily_budget_iqd':  dailyBudgetIqd,
        'runway_days':       runwayDays,
        'last_transaction':  lastTransaction,
      });
    } catch (_) {
      // Silently ignored: widget is a nice-to-have enhancement.
    }
  }
}
