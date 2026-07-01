import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../widgets/glass_card.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  int touchedIndex = -1;

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

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currencyFormat = NumberFormat.simpleCurrency();
    final breakdown = appState.categoryExpensesBreakdown;

    final income = appState.totalMonthlyIncome;
    final expense = appState.totalMonthlyExpenses;
    final netSavings = appState.monthlySavingsRealized;
    final burnRate = income > 0 ? (expense / income).clamp(0.0, 1.0) : 0.0;

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
              const Text(
                'Analysis',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),

              // Overview Cards
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'MONTHLY CASH FLOW',
                      style: TextStyle(
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
                        _buildFlowMetric('Total Income', income, const Color(0xFF10B981)),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.08),
                        ),
                        _buildFlowMetric('Total Spend', expense, const Color(0xFFEF4444)),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.08),
                        ),
                        _buildFlowMetric('Net Savings', netSavings, Colors.white),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Consumption Bar Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Income Consumed',
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

              // Pie Chart Card
              Text(
                'SPENDING BREAKDOWN',
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
                              'No expense data to analyze yet',
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
                                    entry.key,
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
                                      fontWeight: FontWeight.w500,
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlowMetric(String title, double value, Color valColor) {
    final currencyFormat = NumberFormat.simpleCurrency();
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
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: valColor,
          ),
        ),
      ],
    );
  }
}
