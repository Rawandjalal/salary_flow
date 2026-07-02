import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/budget_ring.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/log_daily_earnings_dialog.dart';
import 'payroll_page.dart';
import 'widget_simulator_page.dart';

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
  bool _showGuide = false; // Expanding guide/tips box state

  void _showLogDailyEarnings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LogDailyEarningsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

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

    final width = MediaQuery.of(context).size.width;
    final isWide = width > 768; // Responsiveness break point for desktop/web view

    // Onboarding / Tips Guide Card
    final tipsGuideCard = GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => setState(() => _showGuide = !_showGuide),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tips_and_updates_rounded, color: Colors.amberAccent, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      appState.isRtl ? 'ڕێبەری خێرا و ئامۆژگاری' : 'Quick Guide & Tips',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
                Icon(
                  _showGuide ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white54,
                  size: 20,
                ),
              ],
            ),
          ),
          if (_showGuide) ...[
            const SizedBox(height: 14),
            Divider(color: Colors.white.withOpacity(0.08)),
            const SizedBox(height: 8),
            _buildGuideItem(
              Icons.account_balance_wallet_rounded,
              Colors.cyanAccent,
              appState.isRtl ? 'گۆڕینی جزدان' : 'Switch Wallets',
              appState.isRtl 
                  ? 'لەسەرەوە دۆلار یان دینار هەڵبژێرە بۆ بینینی بودجە بە هەردوو دراو.'
                  : 'Tap USD or IQD wallet above to swap currencies dynamically.',
            ),
            _buildGuideItem(
              Icons.today_rounded,
              Colors.greenAccent,
              appState.isRtl ? 'بودجەی ڕۆژانە' : 'Daily Allowance',
              appState.isRtl 
                  ? 'بودجەی ماوەی ئەمڕۆتە؛ تۆمارکردنی خەرجی کەمیدەکاتەوە و داهات زیادیدەکات.'
                  : 'Your daily remaining budget. Spends decrease it, incomes/sales increase it.',
            ),
            _buildGuideItem(
              Icons.view_headline_rounded,
              Colors.amberAccent,
              appState.isRtl ? 'مەودای بودجە' : 'Time Horizons',
              appState.isRtl 
                  ? 'خەرجییەکانت بۆ ماوەی ڕۆژانە، هەفتانە، مانگانە، و ساڵانە بە ئاسانی کۆنترۆڵ بکە.'
                  : 'Track your spending levels across Daily, Weekly, Monthly, and Yearly intervals.',
            ),
            _buildGuideItem(
              Icons.people_rounded,
              Colors.blueAccent,
              appState.isRtl ? 'لیستی مووچە' : 'Daily Payroll',
              appState.isRtl 
                  ? 'داگرە لەسەر دوگمەی مووچە بۆ دیاریکردنی ئامادەبوونی کارمەند و مووچەی دەستی.'
                  : 'Use Staff Payroll below to record employee attendance and custom daily wages.',
            ),
          ],
        ],
      ),
    );

    // Time Horizons Card
    final remainingWeekly = isUsd ? appState.remainingWeeklyBudgetUSD : appState.remainingWeeklyBudgetIQD;
    final remainingMonthly = isUsd ? appState.remainingMonthlyBudgetUSD : appState.remainingMonthlyBudgetIQD;
    final remainingYearly = isUsd ? appState.remainingYearlyBudgetUSD : appState.remainingYearlyBudgetIQD;

    final limitDaily = dailyAllowance;
    final limitWeekly = dailyAllowance * 7;
    final limitMonthly = dailyAllowance * appState.daysInMonth;
    final limitYearly = dailyAllowance * 365;

    final timeHorizonsCard = GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            appState.t('budget_horizons'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            appState.t('budget_horizons_desc'),
            style: TextStyle(fontSize: 10.5, color: Colors.white.withOpacity(0.5)),
          ),
          const SizedBox(height: 16),
          _buildHorizonRow(
            label: appState.t('daily'),
            remaining: remainingDaily,
            limit: limitDaily,
            formatter: currencyFormat,
            color: const Color(0xFF10B981),
            isRtl: appState.isRtl,
          ),
          const SizedBox(height: 10),
          _buildHorizonRow(
            label: appState.t('weekly'),
            remaining: remainingWeekly,
            limit: limitWeekly,
            formatter: currencyFormat,
            color: Colors.blueAccent,
            isRtl: appState.isRtl,
          ),
          const SizedBox(height: 10),
          _buildHorizonRow(
            label: appState.t('monthly'),
            remaining: remainingMonthly,
            limit: limitMonthly,
            formatter: currencyFormat,
            color: Colors.purpleAccent,
            isRtl: appState.isRtl,
          ),
          const SizedBox(height: 10),
          _buildHorizonRow(
            label: appState.t('yearly'),
            remaining: remainingYearly,
            limit: limitYearly,
            formatter: currencyFormat,
            color: Colors.orangeAccent,
            isRtl: appState.isRtl,
          ),
        ],
      ),
    );

    // Left Column content (on wide screens)
    final Widget leftColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tipsGuideCard,
        const SizedBox(height: 14),
        // Dynamic Budget Ring Card
        GlassCard(
          child: Column(
            children: [
              BudgetRing(
                remainingBudget: remainingDaily,
                dailyAllowance: dailyAllowance,
                ratio: budgetRatio,
                currencySymbol: activeSymbol,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        timeHorizonsCard,
      ],
    );

    // Right Column content (on wide screens)
    final Widget rightColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        const SizedBox(height: 14),

        // End of Day Earnings Card
        GestureDetector(
          onTap: () => _showLogDailyEarnings(context),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F2C2A), Color(0xFF081C1B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.wb_sunny_rounded, color: Color(0xFF10B981), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appState.t('log_daily_earnings'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        appState.t('daily_earnings_desc'),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.3), size: 14),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Staff Payroll Worksheet Launch Card
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PayrollPage()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B223C), Color(0xFF111422)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.people_alt_rounded, color: Colors.blueAccent, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appState.t('staff_payroll'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        appState.t('staff_payroll_desc'),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.3), size: 14),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // iOS Home Screen Widget Simulator Card
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WidgetSimulatorPage()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C1E3C), Color(0xFF161122)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.widgets_rounded, color: Colors.purpleAccent, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appState.t('widget_simulator'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        appState.t('widget_simulator_desc'),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.3), size: 14),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

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
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
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
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
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
      ],
    );

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
                      const SizedBox(height: 18),

                      // Scope Filter Header (Personal vs Business vs Combined)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.04)),
                        ),
                        child: Row(
                          children: [
                            _buildScopeButton(appState, 'personal', appState.t('personal')),
                            _buildScopeButton(appState, 'all', appState.t('all_scopes')),
                            _buildScopeButton(appState, 'business', appState.t('business')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

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
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isUsd ? Colors.white.withOpacity(0.08) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    appState.isRtl ? 'جزدانی دۆلار (\$)' : 'USD Wallet (\$)',
                                    style: TextStyle(
                                      color: isUsd ? Colors.white : Colors.white.withOpacity(0.4),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
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
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: !isUsd ? Colors.white.withOpacity(0.08) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    appState.isRtl ? 'جزدانی دینار (د.ع)' : 'IQD Wallet (د.ع)',
                                    style: TextStyle(
                                      color: !isUsd ? Colors.white : Colors.white.withOpacity(0.4),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Responsive Grid/Row layout for tablet/desktop vs mobile
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 4, child: leftColumn),
                            const SizedBox(width: 18),
                            Expanded(flex: 5, child: rightColumn),
                          ],
                        )
                      else ...[
                        leftColumn,
                        const SizedBox(height: 14),
                        rightColumn,
                      ],
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

                      // Transactions List (reacts to global selected scope filter automatically)
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
    );
  }

  Widget _buildScopeButton(AppState appState, String scope, String label) {
    final isSelected = appState.selectedScope == scope;
    final isBusiness = scope == 'business';
    Color activeColor = Colors.white.withOpacity(0.08);
    if (isSelected) {
      if (isBusiness) activeColor = const Color(0xFF10B981).withOpacity(0.12);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => appState.setSelectedScope(scope),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? (isBusiness ? const Color(0xFF10B981).withOpacity(0.25) : Colors.white.withOpacity(0.12))
                  : Colors.transparent,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected 
                  ? (isBusiness ? const Color(0xFF10B981) : Colors.white) 
                  : Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideItem(IconData icon, Color color, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5), height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizonRow({
    required String label,
    required double remaining,
    required double limit,
    required NumberFormat formatter,
    required Color color,
    required bool isRtl,
  }) {
    final double spent = limit - remaining;
    final double ratio = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final percent = (ratio * 100).toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Colors.white70),
              ),
              Text(
                '${formatter.format(remaining)} / ${formatter.format(limit)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: remaining >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 2),
          Align(
            alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
            child: Text(
              isRtl ? '%$percent خەرجکراوە' : '$percent% spent',
              style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.35)),
            ),
          ),
        ],
      ),
    );
  }
}
