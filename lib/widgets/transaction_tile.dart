import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Transport':
        return Icons.directions_transit_rounded;
      case 'Rent':
        return Icons.home_rounded;
      case 'Entertainment':
        return Icons.sports_esports_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Utilities':
        return Icons.electric_bolt_rounded;
      case 'Salary':
        return Icons.work_rounded;
      default:
        return Icons.monetization_on_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.orangeAccent;
      case 'Transport':
        return Colors.blueAccent;
      case 'Rent':
        return Colors.purpleAccent;
      case 'Entertainment':
        return Colors.pinkAccent;
      case 'Shopping':
        return Colors.tealAccent;
      case 'Utilities':
        return Colors.yellowAccent;
      case 'Salary':
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryTranslation(BuildContext context, String category) {
    final appState = Provider.of<AppState>(context, listen: false);
    switch (category) {
      case 'Food':
        return appState.t('food');
      case 'Transport':
        return appState.t('transport');
      case 'Rent':
        return appState.t('rent');
      case 'Entertainment':
        return appState.t('entertainment');
      case 'Shopping':
        return appState.t('shopping');
      case 'Utilities':
        return appState.t('utilities');
      case 'Salary':
        return appState.t('salary');
      default:
        return appState.t('other');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic currency formatting based on the transaction's currency
    final isUsd = transaction.currency == 'USD';
    final activeSymbol = isUsd ? '\$' : 'د.ع';
    final decimalDigits = isUsd ? 2 : 0;
    final currencyFormat = NumberFormat.currency(
      symbol: activeSymbol,
      decimalDigits: decimalDigits,
    );
    
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getCategoryColor(transaction.category).withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getCategoryIcon(transaction.category),
            color: _getCategoryColor(transaction.category),
            size: 20,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            if (transaction.description.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                transaction.description,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.white.withOpacity(0.45),
                ),
              ),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            '${_getCategoryTranslation(context, transaction.category)} • ${dateFormat.format(transaction.date)}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.35),
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${transaction.isIncome ? '+' : '-'}${currencyFormat.format(transaction.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: transaction.isIncome
                    ? const Color(0xFF10B981) // Emerald Green
                    : Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: Colors.white.withOpacity(0.25),
                size: 20,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
