import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/transaction.dart';
import '../widgets/glass_card.dart';
import '../widgets/budget_ring.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/add_transaction_sheet.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback onViewAllTransactions;

  const DashboardPage({
    super.key,
    required this.onViewAllTransactions,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _activeWallet = 'USD'; // 'USD' or 'IQD'

  void _showAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final appState = Provider.of<AppState>(context, listen: false);
        return AddTransactionSheet(
          onAdd: (tx) => appState.addTransaction(tx),
        );
      },
    );
  }

  void _quickAdd(BuildContext context, String title, double amount, String category, AppState appState) {
    final tx = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      isIncome: false,
      category: category,
      date: DateTime.now(),
      currency: _activeWallet, // Logs in the active wallet currency
    );
    appState.addTransaction(tx);
    
    final displaySymbol = _activeWallet == 'USD' ? '\$' : 'د.ع';
    final decimalDigits = _activeWallet == 'USD' ? 2 : 0;
    final formattedVal = NumberFormat.currency(symbol: displaySymbol, decimalDigits: decimalDigits).format(amount);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${appState.t('add')}: $title ($formattedVal)'),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isRtl = appState.isRtl;

    // Resolve metrics based on the active wallet currency
    final isUsd = _activeWallet == 'USD';
    final activeSymbol = isUsd ? '\$' : 'د.ع';
    final activeDecimals = isUsd ? 2 : 0;

    final currencyFormat = NumberFormat.currency(
      symbol: activeSymbol,
      decimalDigits: activeDecimals,
    );

    final remainingDaily = isUsd ? appState.remainingDailyBudgetUSD : appState.remainingDailyBudgetIQD;
    final dailyAllowance = isUsd ? appState.dailyAllowanceUSD : appState.dailyAllowanceIQD;
    final budgetRatio = isUsd ? appState.budgetUsageRatioUSD : appState.budgetUsageRatioIQD;

    final todaysExpenses = isUsd ? appState.todaysExpensesUSD : appState.todaysExpensesIQD;
    final todaysIncome = isUsd ? appState.todaysIncomeUSD : appState.todaysIncomeIQD;

    final spendVelocity = isUsd ? appState.spendVelocityUSD : appState.spendVelocityIQD;
    final runwayDays = isUsd ? appState.runwayForecastDaysUSD : appState.runwayForecastDaysIQD;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F111E),
              Color(0xFF07080F),
            ],
          ),
        ),
        child: SafeArea(
          child: appState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  color: const Color(0xFF10B981),
                  onRefresh: () async {},
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appState.t('welcome_back'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white.withOpacity(0.4),
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                appState.t('manager_title'),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                            ),
                            child: const CircleAvatar(
                              radius: 20,
                              backgroundColor: Color(0xFF1E2235),
                              child: Icon(Icons.person_rounded, color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Premium Dual-Wallet Selector (USD vs IQD)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _activeWallet = 'USD'),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isUsd ? Colors.white.withOpacity(0.08) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    appState.isRtl ? 'جانتا و دەفتەری دۆلار (\$)' : 'USD Wallet (\$)',
                                    style: TextStyle(
                                      color: isUsd ? Colors.white : Colors.white.withOpacity(0.4),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _activeWallet = 'IQD'),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !isUsd ? Colors.white.withOpacity(0.08) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    appState.isRtl ? 'دەفتەری دیناری عێراقی (د.ع)' : 'IQD Wallet (د.ع)',
                                    style: TextStyle(
                                      color: !isUsd ? Colors.white : Colors.white.withOpacity(0.4),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Dynamic Budget Ring Card
                      GlassCard(
                        child: Column(
                          children: [
                            BudgetRing(
                              remainingBudget: remainingDaily,
                              dailyAllowance: dailyAllowance,
                              ratio: budgetRatio,
                              currencySymbol: activeSymbol, // Passes correct active currency symbol
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Today's Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: GlassCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appState.t('todays_spent'),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white.withOpacity(0.4),
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    currencyFormat.format(todaysExpenses),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GlassCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appState.t('todays_income'),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white.withOpacity(0.4),
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    currencyFormat.format(todaysIncome),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Runway & Spending Velocity Card
                      GlassCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appState.t('runway_card'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white.withOpacity(0.4),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                // Spend Velocity
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        appState.t('velocity'),
                                        style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4)),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.speed_rounded, color: Colors.blueAccent, size: 18),
                                          const SizedBox(width: 6),
                                          Text(
                                            currencyFormat.format(spendVelocity),
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1.2,
                                  height: 36,
                                  color: Colors.white.withOpacity(0.08),
                                ),
                                const SizedBox(width: 16),
                                // Runway Projection
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        appState.t('runway'),
                                        style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4)),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.date_range_rounded, color: Colors.purpleAccent, size: 18),
                                          const SizedBox(width: 6),
                                          Text(
                                            runwayDays == 999
                                                ? appState.t('infinite')
                                                : '$runwayDays ${appState.t('days_left')}',
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Quick presets (Scaled to active wallet currency)
                      Text(
                        appState.t('quick_log'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withOpacity(0.4),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: isUsd
                              ? [
                                  _buildQuickChip(context, '☕ ${appState.t('food')}', 4.50, 'Food', appState),
                                  _buildQuickChip(context, '🍔 ${appState.t('food')}', 14.00, 'Food', appState),
                                  _buildQuickChip(context, '🚌 ${appState.t('transport')}', 3.00, 'Transport', appState),
                                  _buildQuickChip(context, '🍿 ${appState.t('entertainment')}', 12.50, 'Entertainment', appState),
                                  _buildQuickChip(context, '💡 ${appState.t('utilities')}', 45.00, 'Utilities', appState),
                                ]
                              : [
                                  _buildQuickChip(context, '☕ ${appState.t('food')}', 5000, 'Food', appState),
                                  _buildQuickChip(context, '🍔 ${appState.t('food')}', 20000, 'Food', appState),
                                  _buildQuickChip(context, '🚌 ${appState.t('transport')}', 5000, 'Transport', appState),
                                  _buildQuickChip(context, '🍿 ${appState.t('entertainment')}', 15000, 'Entertainment', appState),
                                  _buildQuickChip(context, '💡 ${appState.t('utilities')}', 60000, 'Utilities', appState),
                                ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Recent Transactions Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            appState.t('recent_transactions'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withOpacity(0.4),
                              letterSpacing: 1.5,
                            ),
                          ),
                          TextButton(
                            onPressed: widget.onViewAllTransactions,
                            child: Text(
                              appState.t('see_all'),
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Transactions List (USD + IQD)
                      if (appState.transactions.isEmpty)
                        GlassCard(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_rounded,
                                size: 48,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                appState.t('no_transactions'),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                appState.t('tap_add'),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: appState.transactions.length > 5 ? 5 : appState.transactions.length,
                          itemBuilder: (context, index) {
                            final tx = appState.transactions[index];
                            return TransactionTile(
                              transaction: tx,
                              onDelete: () => appState.deleteTransaction(tx.id),
                            );
                          },
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransaction(context),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _buildQuickChip(BuildContext context, String label, double amount, String category, AppState appState) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: ActionChip(
        label: Text(label),
        labelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        backgroundColor: Colors.white.withOpacity(0.04),
        side: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onPressed: () => _quickAdd(context, label.substring(2), amount, category, appState),
      ),
    );
  }
}
