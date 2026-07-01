import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetRing extends StatelessWidget {
  final double remainingBudget;
  final double dailyAllowance;
  final double ratio; // 0.0 to 1.0 representation of spent
  final String currencySymbol;

  const BudgetRing({
    super.key,
    required this.remainingBudget,
    required this.dailyAllowance,
    required this.ratio,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final isExceeded = remainingBudget < 0;
    final displayRatio = isExceeded ? 1.0 : (1.0 - ratio).clamp(0.0, 1.0);

    // Dynamic coloring based on budget status
    final primaryColor = isExceeded
        ? const Color(0xFFEF4444) // Neon Red
        : ratio > 0.8
            ? const Color(0xFFF59E0B) // Amber Orange
            : const Color(0xFF10B981); // Emerald Green

    // Dynamic formatting
    final decimalDigits = currencySymbol == '\$' ? 2 : 0;
    final formatter = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: decimalDigits,
    );

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 16,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
          // Progress track
          SizedBox(
            width: 200,
            height: 200,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: displayRatio),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 16,
                  color: primaryColor,
                  strokeCap: StrokeCap.round,
                );
              },
            ),
          ),
          // Inner Info
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isExceeded ? 'EXCEEDED BY' : 'BUDGET LEFT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.4),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formatter.format(remainingBudget.abs()),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isExceeded ? const Color(0xFFEF4444) : Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Allowance: ${formatter.format(dailyAllowance)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.35),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
