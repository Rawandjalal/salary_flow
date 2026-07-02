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
      case 'Rent/Office':
        return Icons.home_rounded;
      case 'Entertainment':
        return Icons.sports_esports_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Utilities':
        return Icons.electric_bolt_rounded;
      case 'Salary':
        return Icons.work_rounded;
      case 'Medical':
        return Icons.medical_services_rounded;
      case 'Education':
        return Icons.school_rounded;
      case 'Gift':
        return Icons.volunteer_activism_rounded;
      case 'Freelance/Side Hustle':
        return Icons.laptop_mac_rounded;
      case 'Investments':
        return Icons.trending_up_rounded;
      case 'Inventory/Stock':
        return Icons.inventory_2_rounded;
      case 'Marketing/Ads':
        return Icons.campaign_rounded;
      case 'Salaries/Wages':
        return Icons.groups_rounded;
      case 'Software/Tools':
        return Icons.terminal_rounded;
      case 'Logistics/Shipping':
        return Icons.local_shipping_rounded;
      case 'Taxes/Fees':
        return Icons.receipt_rounded;
      case 'Office Supplies':
        return Icons.border_color_rounded;
      case 'Sales/Revenue':
        return Icons.point_of_sale_rounded;
      case 'Service/Consulting':
        return Icons.handshake_rounded;
      case 'Capital Deposit':
        return Icons.account_balance_rounded;
      case 'Refund/Return':
        return Icons.assignment_return_rounded;
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
      case 'Rent/Office':
        return Colors.cyan;
      case 'Entertainment':
        return Colors.pinkAccent;
      case 'Shopping':
        return Colors.tealAccent;
      case 'Utilities':
        return Colors.yellowAccent;
      case 'Salary':
      case 'Sales/Revenue':
        return Colors.greenAccent;
      case 'Medical':
        return Colors.redAccent;
      case 'Education':
        return Colors.amberAccent;
      case 'Gift':
        return Colors.pink;
      case 'Freelance/Side Hustle':
        return Colors.indigoAccent;
      case 'Investments':
        return Colors.lightGreenAccent;
      case 'Inventory/Stock':
        return Colors.brown;
      case 'Marketing/Ads':
        return Colors.deepOrangeAccent;
      case 'Salaries/Wages':
        return Colors.teal;
      case 'Software/Tools':
        return Colors.blueGrey;
      case 'Logistics/Shipping':
        return Colors.amber;
      case 'Taxes/Fees':
        return Colors.red;
      case 'Office Supplies':
        return Colors.grey;
      case 'Service/Consulting':
        return Colors.purple;
      case 'Capital Deposit':
        return Colors.indigo;
      case 'Refund/Return':
        return Colors.orange;
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
      case 'Medical':
        return appState.t('medical');
      case 'Education':
        return appState.t('education');
      case 'Gift':
        return appState.t('gift');
      case 'Freelance/Side Hustle':
        return appState.t('freelance');
      case 'Investments':
        return appState.t('investments');
      case 'Inventory/Stock':
        return appState.t('inventory');
      case 'Rent/Office':
        return appState.isRtl ? 'کرێ/پسوولە' : 'Rent / Office';
      case 'Marketing/Ads':
        return appState.t('marketing');
      case 'Salaries/Wages':
        return appState.t('salaries');
      case 'Software/Tools':
        return appState.t('software');
      case 'Logistics/Shipping':
        return appState.t('logistics');
      case 'Taxes/Fees':
        return appState.t('taxes');
      case 'Office Supplies':
        return appState.t('office_supplies');
      case 'Sales/Revenue':
        return appState.t('sales_revenue');
      case 'Service/Consulting':
        return appState.t('service_consulting');
      case 'Capital Deposit':
        return appState.t('capital');
      case 'Refund/Return':
        return appState.t('refund');
      default:
        return appState.t('other');
    }
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'Cash':
        return Icons.money_rounded;
      case 'Card':
        return Icons.credit_card_rounded;
      case 'Transfer':
        return Icons.send_rounded;
      case 'Debt':
        return Icons.hourglass_empty_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isUsd = transaction.currency == 'USD';
    final activeSymbol = isUsd ? '\$' : 'د.ع';
    final decimalDigits = isUsd ? 2 : 0;
    final currencyFormat = NumberFormat.currency(
      symbol: activeSymbol,
      decimalDigits: decimalDigits,
    );
    
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isBusiness = transaction.scope == 'business';

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    transaction.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Scope Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isBusiness 
                        ? const Color(0xFF10B981).withOpacity(0.15) 
                        : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isBusiness 
                          ? const Color(0xFF10B981).withOpacity(0.3) 
                          : Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    appState.t(transaction.scope),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: isBusiness ? const Color(0xFF10B981) : Colors.white70,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
            if (transaction.description.isNotEmpty || transaction.contact.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (transaction.description.isNotEmpty)
                    Expanded(
                      child: Text(
                        transaction.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                          color: Colors.white.withOpacity(0.45),
                        ),
                      ),
                    ),
                  if (transaction.contact.isNotEmpty) ...[
                    if (transaction.description.isNotEmpty) const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_outline_rounded, size: 10, color: Colors.white.withOpacity(0.4)),
                          const SizedBox(width: 3),
                          Text(
                            transaction.contact,
                            style: TextStyle(fontSize: 9.5, color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Row(
            children: [
              Text(
                '${_getCategoryTranslation(context, transaction.category)} • ${dateFormat.format(transaction.date)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.35),
                ),
              ),
              const SizedBox(width: 6),
              // Payment Method Icon
              Icon(
                _getPaymentIcon(transaction.paymentMethod),
                size: 11,
                color: Colors.white.withOpacity(0.3),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${transaction.isIncome ? '+' : '-'}${currencyFormat.format(transaction.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
                color: transaction.isIncome
                    ? const Color(0xFF10B981) // Emerald Green
                    : Colors.white,
              ),
            ),
            const SizedBox(width: 4),
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
