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
  String _activeWallet = 'USD'; // 'USD' or 'IQD'

  // Simulator Local state changes for Lockscreen banner
  double _lastSimulatedChange = 0.0;
  String _lastSimulatedType = '';

  late TextEditingController _add1Controller;
  late TextEditingController _add2Controller;
  late TextEditingController _sub1Controller;
  late TextEditingController _sub2Controller;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _add1Controller = TextEditingController(text: appState.widgetQuickAdd1.toStringAsFixed(0));
    _add2Controller = TextEditingController(text: appState.widgetQuickAdd2.toStringAsFixed(0));
    _sub1Controller = TextEditingController(text: appState.widgetQuickSub1.toStringAsFixed(0));
    _sub2Controller = TextEditingController(text: appState.widgetQuickSub2.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _add1Controller.dispose();
    _add2Controller.dispose();
    _sub1Controller.dispose();
    _sub2Controller.dispose();
    super.dispose();
  }

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

  void _savePresets() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final add1 = double.tryParse(_add1Controller.text);
    final add2 = double.tryParse(_add2Controller.text);
    final sub1 = double.tryParse(_sub1Controller.text);
    final sub2 = double.tryParse(_sub2Controller.text);

    if (add1 == null || add2 == null || sub1 == null || sub2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appState.t('invalid_numbers')),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    // Unfocus text fields to dismiss keyboard
    FocusScope.of(context).unfocus();

    await appState.saveWidgetPresets(
      quickAdd1: add1,
      quickAdd2: add2,
      quickSub1: sub1,
      quickSub2: sub2,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appState.t('widget_presets_saved')),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isRtl = appState.isRtl;
    final symbol = _activeWallet == 'USD' ? '\$' : 'د.ع';

    // Fetch dynamic numbers for the widget from appState
    final isUsd = _activeWallet == 'USD';
    final remainingDaily = isUsd ? appState.remainingDailyBudgetUSD : appState.remainingDailyBudgetIQD;
    final runwayDays = isUsd ? appState.runwayForecastDaysUSD : appState.runwayForecastDaysIQD;

    // Load presets from AppState
    final qAdd1 = appState.widgetQuickAdd1;
    final qAdd2 = appState.widgetQuickAdd2;
    final qSub1 = appState.widgetQuickSub1;
    final qSub2 = appState.widgetQuickSub2;
    final wStyle = appState.widgetStyle;

    // Build the Widget design based on selected style
    BoxDecoration widgetDecoration;
    Color textColor = Colors.white;
    Color accentColor = const Color(0xFF10B981);

    if (wStyle == 'Neon Cyber') {
      widgetDecoration = BoxDecoration(
        color: const Color(0xFF0D0E15),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF43F5E), width: 2),
        boxShadow: [
          BoxShadow(color: const Color(0xFFF43F5E).withOpacity(0.15), blurRadius: 16),
        ],
      );
      accentColor = const Color(0xFFF43F5E);
    } else if (wStyle == 'Deep Carbon') {
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
                                            _buildWidgetActionButton('+${qAdd1.toStringAsFixed(0)}', const Color(0xFF10B981), () {
                                              _triggerSimulatedAction('Income', qAdd1, true);
                                            }),
                                            const SizedBox(width: 6),
                                            _buildWidgetActionButton('+${qAdd2.toStringAsFixed(0)}', const Color(0xFF10B981), () {
                                              _triggerSimulatedAction('Income', qAdd2, true);
                                            }),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            _buildWidgetActionButton('-${qSub1.toStringAsFixed(0)}', const Color(0xFFEF4444), () {
                                              _triggerSimulatedAction('Expense', qSub1, false);
                                            }),
                                            const SizedBox(width: 6),
                                            _buildWidgetActionButton('-${qSub2.toStringAsFixed(0)}', const Color(0xFFEF4444), () {
                                              _triggerSimulatedAction('Expense', qSub2, false);
                                            }),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        _buildWidgetActionButton(
                                          isRtl ? '✏️ بڕی دەستی' : '✏️ Custom',
                                          Colors.orangeAccent,
                                          () => _showManualEntryDialog(context),
                                          width: 114,
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

              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: () => _showSetupBottomSheet(context),
                  icon: const Icon(Icons.help_outline_rounded, color: Colors.amberAccent, size: 18),
                  label: Text(
                    isRtl ? 'چۆن وێجێتی ڕاستەقینە دابنێم لەسەر شاشەی ئایفۆنەکەم؟' : 'How to add real widget to iPhone home screen?',
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
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
                        _buildStyleChip(context, 'Glassmorphism', wStyle),
                        const SizedBox(width: 8),
                        _buildStyleChip(context, 'Neon Cyber', wStyle),
                        const SizedBox(width: 8),
                        _buildStyleChip(context, 'Deep Carbon', wStyle),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Quick presets fields
                    Text(
                      isRtl ? 'ڕێکخستنی بڕە خێراکان' : 'Customize Quick Preset Shortcuts',
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _add1Controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: isRtl ? 'داهات ١' : 'Income A',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.02),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _add2Controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: isRtl ? 'داهات ٢' : 'Income B',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.02),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _sub1Controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: isRtl ? 'خەرجی ١' : 'Expense A',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.02),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _sub2Controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: isRtl ? 'خەرجی ٢' : 'Expense B',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.02),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Action button to Save Presets
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _savePresets,
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: Text(appState.t('save_widget_presets'), style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildWidgetActionButton(String label, Color color, VoidCallback onTap, {double width = 54}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: width,
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

  Widget _buildStyleChip(BuildContext context, String name, String currentStyle) {
    final isSelected = currentStyle == name;
    final appState = Provider.of<AppState>(context, listen: false);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          appState.updateWidgetStyle(name);
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

  void _showManualEntryDialog(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final isRtl = appState.isRtl;
    final controller = TextEditingController();
    bool isIncome = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF111422),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                isRtl ? 'تۆمارکردنی دەستی وێجێت' : 'Widget Manual Entry',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Text(isRtl ? 'خەرجی' : 'Expense'),
                          selected: !isIncome,
                          selectedColor: const Color(0xFFEF4444).withOpacity(0.2),
                          checkmarkColor: const Color(0xFFEF4444),
                          labelStyle: TextStyle(color: !isIncome ? const Color(0xFFEF4444) : Colors.white60, fontWeight: FontWeight.bold),
                          onSelected: (val) => setDialogState(() => isIncome = false),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: Text(isRtl ? 'داهات' : 'Income'),
                          selected: isIncome,
                          selectedColor: const Color(0xFF10B981).withOpacity(0.2),
                          checkmarkColor: const Color(0xFF10B981),
                          labelStyle: TextStyle(color: isIncome ? const Color(0xFF10B981) : Colors.white60, fontWeight: FontWeight.bold),
                          onSelected: (val) => setDialogState(() => isIncome = true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: isRtl ? 'بڕی پارە بنووسە...' : 'Enter amount...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                      suffixText: _activeWallet,
                      suffixStyle: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.04),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isRtl ? 'پاشگەزبوونەوە' : 'Cancel', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final amt = double.tryParse(controller.text);
                    if (amt != null && amt > 0) {
                      Navigator.pop(context);
                      _triggerSimulatedAction(
                        isIncome ? 'Income' : 'Expense', 
                        amt, 
                        isIncome,
                      );
                    }
                  },
                  child: Text(isRtl ? 'تۆمارکردن' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSetupBottomSheet(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final isRtl = appState.isRtl;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111422),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isRtl ? 'چۆنیەتی زیادکردنی وێجێت' : 'How to Add Widget',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isRtl 
                      ? 'سیستمی iOS ڕێگە نادات بە شێوەی ئۆتۆماتیکی وێجێت زیاد بکرێت. تکایە ئەم هەنگاوانە پەیڕەو بکە:' 
                      : 'iOS does not support automatic widget pinning. Please follow these manual steps to add it:',
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildModalStepRow('1', Icons.touch_app_rounded, Colors.amber, 
                  isRtl ? 'شاشەی سەرەکی ئایفۆنەکەت دابگرە تاوەکو ئایکۆنەکان دەست بە لەرینەوە دەکەن.' : 'Press and hold your Home Screen background until icons wiggle.'),
                _buildModalStepRow('2', Icons.add_circle_outline_rounded, Colors.blueAccent, 
                  isRtl ? 'لە سەرەوە لای چەپ/ڕاست کلیک لە نیشانەی (+) بکە.' : 'Tap the (+) plus icon in the top corner.'),
                _buildModalStepRow('3', Icons.search_rounded, Colors.purpleAccent, 
                  isRtl ? 'بگەڕێ بۆ ناوی "SalaryFlow" لە لیستی بەرنامەکان.' : 'Search for "SalaryFlow" in the widget library.'),
                _buildModalStepRow('4', Icons.crop_landscape_rounded, Colors.greenAccent, 
                  isRtl ? 'قەبارەی مامناوەند (Medium) هەڵبژێرە و داگرە لەسەر Add Widget.' : 'Select the Medium widget layout and tap "Add Widget".'),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Colors.amberAccent, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isRtl
                              ? 'تێبینی: پاراستنی ئاسایشی ئەپڵ ئەم کردارەی سنووردار کردووە، بۆیە هیچ ئەپێک ناتوانێت وێجێت بە ئۆتۆماتیکی دابنێت.'
                              : 'Note: iOS security strictly requires manual placement. No application can pin widgets automatically.',
                          style: TextStyle(fontSize: 10.5, color: Colors.white.withOpacity(0.6), height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E2235),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(isRtl ? 'تێگەیشتم' : 'Got it'),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalStepRow(String step, IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step $step',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white38),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
