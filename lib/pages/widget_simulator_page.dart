import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/transaction.dart';
import '../widgets/glass_card.dart';

class WidgetSimulatorPage extends StatefulWidget {
  const WidgetSimulatorPage({super.key});

  @override
  State<WidgetSimulatorPage> createState() => _WidgetSimulatorPageState();
}

class _WidgetSimulatorPageState extends State<WidgetSimulatorPage> {
  // Widget Customizer States
  String _widgetStyle = 'Glassmorphism'; // 'Glassmorphism', 'Neon Cyber', 'Deep Carbon'
  String _activeWallet = 'USD'; // 'USD' or 'IQD'
  double _quickAdd1 = 20.0;
  double _quickAdd2 = 50.0;
  double _quickSub1 = 10.0;
  double _quickSub2 = 25.0;

  // Simulator Local state changes
  double _lastSimulatedChange = 0.0;
  String _lastSimulatedType = '';

  void _triggerSimulatedAction(String type, double amount, bool isIncome) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final isRtl = appState.isRtl;

    // Create and add actual transaction
    final tx = Transaction(
      id: 'widget_sim_${DateTime.now().millisecondsSinceEpoch}',
      title: isIncome 
          ? (isRtl ? 'داهاتی خێرا (وێجێت)' : 'Quick Income (Widget)')
          : (isRtl ? 'خەرجی خێرا (وێجێت)' : 'Quick Expense (Widget)'),
      amount: amount,
      currency: _activeWallet,
      category: isIncome ? 'salary' : 'food',
      date: DateTime.now(),
      isIncome: isIncome,
      scope: 'business',
      paymentMethod: 'cash',
      contact: 'iOS Widget Link',
      description: isRtl ? 'تۆمارکرا لە ڕێگەی وێجێتی سەرەکی' : 'Logged via Home Screen Widget shortcut',
    );

    await appState.addTransaction(tx);

    setState(() {
      _lastSimulatedChange = amount;
      _lastSimulatedType = type;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRtl 
                ? 'مامەڵە بە بڕی $amount $_activeWallet لە ڕێگەی وێجێتەوە زیادکرا!'
                : 'Transaction of $amount $_activeWallet added via widget shortlink!',
          ),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isRtl = appState.isRtl;
    final symbol = _activeWallet == 'USD' ? '\$' : 'د.ع';

    // Fetch dynamic numbers for the widget
    final isUsd = _activeWallet == 'USD';
    final remainingDaily = isUsd ? appState.remainingDailyBudgetUSD : appState.remainingDailyBudgetIQD;
    final runwayDays = isUsd ? appState.runwayForecastDaysUSD : appState.runwayForecastDaysIQD;

    // Build the Widget design based on selected style
    BoxDecoration widgetDecoration;
    Color textColor = Colors.white;
    Color accentColor = const Color(0xFF10B981);

    if (_widgetStyle == 'Neon Cyber') {
      widgetDecoration = BoxDecoration(
        color: const Color(0xFF0D0E15),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF43F5E), width: 2),
        boxShadow: [
          BoxShadow(color: const Color(0xFFF43F5E).withOpacity(0.15), blurRadius: 16),
        ],
      );
      accentColor = const Color(0xFFF43F5E);
    } else if (_widgetStyle == 'Deep Carbon') {
      widgetDecoration = BoxDecoration(
        color: const Color(0xFF161824),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10),
        ],
      );
      accentColor = const Color(0xFF10B981);
    } else {
      // Glassmorphism default
      widgetDecoration = BoxDecoration(
        color: const Color(0xFF111422).withOpacity(0.7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12),
        ],
      );
      accentColor = const Color(0xFF10B981);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF07080F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111422),
        title: Text(appState.t('widget_simulator')),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F111E), Color(0xFF07080F)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // iPhone frame simulator
              Center(
                child: Container(
                  width: 320,
                  height: 480,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(42),
                    border: Border.all(color: const Color(0xFF2E303A), width: 8),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 30, offset: const Offset(0, 15)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(34),
                    child: Stack(
                      children: [
                        // iOS Lockscreen Wallpaper
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF2C1B4D), Color(0xFF122C3A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        // Mock iOS status indicators
                        Positioned(
                          top: 10,
                          left: 24,
                          right: 24,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('9:41', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              Icon(Icons.battery_5_bar_rounded, color: Colors.white, size: 14),
                            ],
                          ),
                        ),

                        // Interactive Simulated Widget (iOS Medium Widget layout)
                        Positioned(
                          top: 45,
                          left: 16,
                          right: 16,
                          child: Container(
                            height: 160,
                            decoration: widgetDecoration,
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.auto_awesome_rounded, color: Color(0xFF10B981), size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          'SalaryFlow',
                                          style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: accentColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                                      child: Text(
                                        'iOS Shortlink',
                                        style: TextStyle(color: accentColor, fontSize: 8, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            isRtl ? 'بودجەی ماوە' : 'DAILY BUDGET',
                                            style: TextStyle(color: textColor.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${remainingDaily.toStringAsFixed(0)} $symbol',
                                            style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            runwayDays == 999 
                                                ? (isRtl ? 'کاتی مانەوە: بێکۆتایی' : 'Runway: Infinite')
                                                : (isRtl ? 'مەودا: $runwayDays ڕۆژ' : 'Runway: $runwayDays Days'),
                                            style: TextStyle(color: accentColor, fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Custom fast presetting buttons inside the widget!
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            _buildWidgetActionButton('+$_quickAdd1', const Color(0xFF10B981), () {
                                              _triggerSimulatedAction('Income', _quickAdd1, true);
                                            }),
                                            const SizedBox(width: 6),
                                            _buildWidgetActionButton('+$_quickAdd2', const Color(0xFF10B981), () {
                                              _triggerSimulatedAction('Income', _quickAdd2, true);
                                            }),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            _buildWidgetActionButton('-$_quickSub1', const Color(0xFFEF4444), () {
                                              _triggerSimulatedAction('Expense', _quickSub1, false);
                                            }),
                                            const SizedBox(width: 6),
                                            _buildWidgetActionButton('-$_quickSub2', const Color(0xFFEF4444), () {
                                              _triggerSimulatedAction('Expense', _quickSub2, false);
                                            }),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Active Wallet Toggle on mock home screen
                        Positioned(
                          top: 215,
                          left: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _activeWallet = 'USD'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _activeWallet == 'USD' ? Colors.white.withOpacity(0.08) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text('USD (\$)', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _activeWallet = 'IQD'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _activeWallet == 'IQD' ? Colors.white.withOpacity(0.08) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text('IQD (د.ع)', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Simulated result message on iPhone lock screen
                        if (_lastSimulatedChange > 0)
                          Positioned(
                            bottom: 50,
                            left: 30,
                            right: 30,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.notifications_active_rounded, color: Colors.amber, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Logged $_lastSimulatedType: $_lastSimulatedChange $symbol',
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Widget Customizer options
              Text(
                isRtl ? 'ڕێکخستنی شێوازی وێجێت' : 'Widget Customizer Options',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),

              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Widget visual theme selector
                    Text(
                      isRtl ? 'ڕووکاری وێجێت' : 'Widget Visual Style',
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStyleChip('Glassmorphism'),
                        const SizedBox(width: 8),
                        _buildStyleChip('Neon Cyber'),
                        const SizedBox(width: 8),
                        _buildStyleChip('Deep Carbon'),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Quick presets fields
                    Text(
                      isRtl ? 'ڕێکخستنی بڕە خێراکان' : 'Customize Quick Preset Shortcuts',
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _quickAdd1.toStringAsFixed(0),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Income A',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.02),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _quickAdd1 = double.tryParse(val) ?? 20.0;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: _quickAdd2.toStringAsFixed(0),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Income B',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.02),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _quickAdd2 = double.tryParse(val) ?? 50.0;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _quickSub1.toStringAsFixed(0),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Expense A',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.02),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _quickSub1 = double.tryParse(val) ?? 10.0;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: _quickSub2.toStringAsFixed(0),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Expense B',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.02),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _quickSub2 = double.tryParse(val) ?? 25.0;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Steps to Setup on real iPhone
              Text(
                appState.t('widget_setup_guide'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),

              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepRow('1', isRtl ? 'شاشەی ئایفۆنەکەت دابگرە تاوەکو ئایکۆنەکان دەست بە لەرینەوە دەکەن.' : 'Press and hold your iPhone home screen background until icons wiggle.'),
                    _buildStepRow('2', isRtl ? 'لە سەرەوە لای چەپ کلیک لە نیشانەی (+) بکە.' : 'Tap the (+) plus icon in the top-left corner.'),
                    _buildStepRow('3', isRtl ? 'بگەڕێ بۆ ناوی "SalaryFlow" و قەبارەی وێجێت دیاری بکە.' : 'Search for "SalaryFlow" and select the medium widget size.'),
                    _buildStepRow('4', isRtl ? 'داگرە لەسەر (Add Widget) بۆ دانانی لەسەر شاشە.' : 'Tap "Add Widget" to place it onto your dashboard.'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetActionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _buildStyleChip(String name) {
    final isSelected = _widgetStyle == name;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _widgetStyle = name;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF10B981).withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF10B981) : Colors.white.withOpacity(0.08),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            name,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow(String num, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 9,
            backgroundColor: const Color(0xFF10B981).withOpacity(0.2),
            child: Text(num, style: const TextStyle(fontSize: 9, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 11.5, color: Colors.white.withOpacity(0.85), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
