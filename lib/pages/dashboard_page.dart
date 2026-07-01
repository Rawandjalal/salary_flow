import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/transaction.dart';
import '../widgets/glass_card.dart';
import '../widgets/budget_ring.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/add_transaction_sheet.dart';

class DashboardPage extends StatelessWidget {
  final VoidCallback onViewAllTransactions;

  const DashboardPage({
    super.key,
    required this.onViewAllTransactions,
  });

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

  void _quickAdd(BuildContext context, String title, double amount, String category) {
    final appState = Provider.of<AppState>(context, listen: false);
    final tx = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      isIncome: false,
      category: category,
      date: DateTime.now(),
    );
    appState.addTransaction(tx);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $title (\$$amount)'),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currencyFormat = NumberFormat.simpleCurrency();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F111E), // Deep space blue/black
              Color(0xFF07080F),
            ],
          ),
        ),
        child: SafeArea(
          child: appState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  color: const Color(0xFF10B981),
                  onRefresh: () async {
                    // Pull to refresh could re-load, already synced locally
                  },
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
                                'WELCOME BACK',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withOpacity(0.4),
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'SalaryFlow Manager',
                                style: TextStyle(
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
                      const SizedBox(height: 24),

                      // Budget Ring Card
                      GlassCard(
                        child: Column(
                          children: [
                            BudgetRing(
                              remainingBudget: appState.remainingDailyBudget,
                              dailyAllowance: appState.dailyAllowance,
                              ratio: appState.budgetUsageRatio,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

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
                                    "TODAY'S SPENT",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white.withOpacity(0.4),
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    currencyFormat.format(appState.todaysExpenses),
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
                                    "TODAY'S INCOME",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white.withOpacity(0.4),
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    currencyFormat.format(appState.todaysIncome),
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
                      const SizedBox(height: 24),

                      // Quick presets
                      Text(
                        'QUICK LOG EXPENSE',
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
                          children: [
                            _buildQuickChip(context, '☕ Coffee', 4.50, 'Food'),
                            _buildQuickChip(context, '🍔 Lunch', 14.00, 'Food'),
                            _buildQuickChip(context, '🚌 Commute', 3.00, 'Transport'),
                            _buildQuickChip(context, '🍿 Cinema', 12.50, 'Entertainment'),
                            _buildQuickChip(context, '💡 Bill', 45.00, 'Utilities'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Recent Transactions Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "RECENT TRANSACTIONS",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withOpacity(0.4),
                              letterSpacing: 1.5,
                            ),
                          ),
                          TextButton(
                            onPressed: onViewAllTransactions,
                            child: const Text(
                              'See All',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Transactions List
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
                                'No transactions logged yet',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tap the + button to add one',
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
                          itemCount: appState.transactions.length > 4 ? 4 : appState.transactions.length,
                          itemBuilder: (context, index) {
                            final tx = appState.transactions[index];
                            return TransactionTile(
                              transaction: tx,
                              onDelete: () => appState.deleteTransaction(tx.id),
                            );
                          },
                        ),
                      const SizedBox(height: 80), // bottom offset for FAB
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

  Widget _buildQuickChip(BuildContext context, String label, double amount, String category) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: ActionChip(
        label: Text(label),
        labelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        backgroundColor: Colors.white.withOpacity(0.04),
        side: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onPressed: () => _quickAdd(context, label.substring(2), amount, category),
      ),
    );
  }
}
