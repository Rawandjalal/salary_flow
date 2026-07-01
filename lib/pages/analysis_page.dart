import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/transaction.dart';
import '../widgets/glass_card.dart';
import '../widgets/financial_health_gauge.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  int touchedIndex = -1;
  String _activeCurrency = 'USD'; // 'USD' or 'IQD' to segment analysis charts

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

  List<PieChartSectionData> _getSections(Map<String, double> breakdown) {
    if (breakdown.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.white.withOpacity(0.08),
          value: 100,
          title: '',
          radius: 35,
        )
      ];
    }

    final total = breakdown.values.fold(0.0, (sum, val) => sum + val);

    int index = 0;
    return breakdown.entries.map((entry) {
      final isTouched = index == touchedIndex;
      final radius = isTouched ? 45.0 : 35.0;
      final percentage = (entry.value / total) * 100;
      final color = _getCategoryColor(entry.key);
      index++;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: percentage > 8 ? '${percentage.toStringAsFixed(0)}%' : '',
        radius: radius,
        showTitle: true,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<FlSpot> _getSpendingTrendSpots(List<Transaction> transactions, int days, String currency) {
    final now = DateTime.now();
    final dailyTotals = Map<int, double>.fromIterable(
      List.generate(days, (i) => i + 1),
      key: (item) => item as int,
      value: (item) => 0.0,
    );

    for (var tx in transactions) {
      if (!tx.isIncome && tx.currency == currency && tx.date.year == now.year && tx.date.month == now.month) {
        final day = tx.date.day;
        dailyTotals[day] = (dailyTotals[day] ?? 0.0) + tx.amount;
      }
    }

    return dailyTotals.entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // Currency Formatter resolving
    final isUsd = _activeCurrency == 'USD';
    final activeSymbol = isUsd ? '\$' : 'د.ع';
    final activeDecimals = isUsd ? 2 : 0;

    final currencyFormat = NumberFormat.currency(
      symbol: activeSymbol,
      decimalDigits: activeDecimals,
    );

    // Resolve Breakdown Map
    final breakdown = appState.getCategoryExpensesBreakdown(_activeCurrency);

    // Resolve Cash Flow metrics
    final income = isUsd ? appState.totalMonthlyIncomeUSD : appState.totalMonthlyIncomeIQD;
    final expense = isUsd ? appState.totalMonthlyExpensesUSD : appState.totalMonthlyExpensesIQD;
    final netSavings = isUsd ? appState.monthlySavingsRealizedUSD : appState.monthlySavingsRealizedIQD;
    final burnRate = income > 0 ? (expense / income).clamp(0.0, 1.0) : 0.0;

    // Resolve Health Index
    final healthScore = isUsd ? appState.financialHealthScoreUSD : appState.financialHealthScoreIQD;
    String healthFeedback = appState.t('health_poor');
    if (healthScore >= 80) {
      healthFeedback = appState.t('health_excellent');
    } else if (healthScore >= 50) {
      healthFeedback = appState.t('health_good');
    } else if (healthScore >= 30) {
      healthFeedback = appState.t('health_fair');
    }

    // Line Chart Spots
    final daysInCurrentMonth = appState.daysInMonth;
    final trendSpots = _getSpendingTrendSpots(appState.transactions, daysInCurrentMonth, _activeCurrency);

    double maxSpentOnADay = 100.0;
    for (var spot in trendSpots) {
      if (spot.y > maxSpentOnADay) {
        maxSpentOnADay = spot.y;
      }
    }

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
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                appState.t('analysis'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 18),

              // Wallet Analysis Toggle Buttons
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
                        onTap: () => setState(() => _activeCurrency = 'USD'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isUsd ? Colors.white.withOpacity(0.08) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            appState.isRtl ? 'دۆلار (\$)' : 'USD (\$)',
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
                        onTap: () => setState(() => _activeCurrency = 'IQD'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !isUsd ? Colors.white.withOpacity(0.08) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            appState.isRtl ? 'دینار (د.ع)' : 'IQD (د.ع)',
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
              const SizedBox(height: 24),

              // Financial Health Gauge Card
              Text(
                appState.t('financial_health'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.4),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: FinancialHealthGauge(
                    score: healthScore,
                    feedbackText: healthFeedback,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Overview Cards
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      appState.t('cash_flow'),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white54,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFlowMetric(appState.t('flow_income'), income, const Color(0xFF10B981), currencyFormat),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.08),
                        ),
                        _buildFlowMetric(appState.t('flow_spend'), expense, const Color(0xFFEF4444), currencyFormat),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.08),
                        ),
                        _buildFlowMetric(appState.t('flow_savings'), netSavings, Colors.white, currencyFormat),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          appState.t('burn_rate'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        Text(
                          '${(burnRate * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: burnRate > 0.8 ? const Color(0xFFEF4444) : Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: burnRate,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        color: burnRate > 0.8 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Daily Spending Trend Line Chart
              Text(
                appState.isRtl ? 'ڕەوتی خەرجی ڕۆژانە' : 'DAILY SPENDING TREND',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.4),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: SizedBox(
                  height: 180,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15, right: 10, left: 5, bottom: 5),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.white.withOpacity(0.05),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              interval: 7,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 42,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  currencyFormat.format(value),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 1,
                        maxX: daysInCurrentMonth.toDouble(),
                        minY: 0,
                        maxY: maxSpentOnADay * 1.15,
                        lineBarsData: [
                          LineChartBarData(
                            spots: trendSpots,
                            isCurved: true,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEF4444), Color(0xFFF59E0B)],
                            ),
                            barWidth: 3.5,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFEF4444).withOpacity(0.2),
                                  const Color(0xFFF59E0B).withOpacity(0.02),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Pie Chart Card (Spending Breakdown)
              Text(
                appState.t('spending_breakdown'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.4),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: breakdown.isEmpty
                    ? Container(
                        height: 220,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pie_chart_outline_rounded,
                              size: 44,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              appState.t('no_expense_data'),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: 180,
                            child: PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          pieTouchResponse == null ||
                                          pieTouchResponse.touchedSection == null) {
                                        touchedIndex = -1;
                                        return;
                                      }
                                      touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                    });
                                  },
                                ),
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 4,
                                centerSpaceRadius: 40,
                                sections: _getSections(breakdown),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Legends
                          ...breakdown.entries.map((entry) {
                            final total = breakdown.values.fold(0.0, (sum, val) => sum + val);
                            final pct = (entry.value / total) * 100;
                            final color = _getCategoryColor(entry.key);
                            final localizedCatName = _getCategoryTranslation(context, entry.key);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    localizedCatName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    currencyFormat.format(entry.value),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${pct.toStringAsFixed(1)}%)',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlowMetric(String title, double value, Color valColor, NumberFormat currencyFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          currencyFormat.format(value),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: valColor,
          ),
        ),
      ],
    );
  }
}
