import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/transaction.dart';

class LogDailyEarningsDialog extends StatefulWidget {
  const LogDailyEarningsDialog({super.key});

  @override
  State<LogDailyEarningsDialog> createState() => _LogDailyEarningsDialogState();
}

class _LogDailyEarningsDialogState extends State<LogDailyEarningsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usdController = TextEditingController();
  final _iqdController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedScope = 'business'; // Defaults to business earnings
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _usdController.dispose();
    _iqdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, AppState appState) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF10B981),
              onPrimary: Colors.white,
              surface: Color(0xFF161B2E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit(BuildContext context, AppState appState) {
    if (!_formKey.currentState!.validate()) return;

    final usdAmount = double.tryParse(_usdController.text.trim()) ?? 0.0;
    final iqdAmount = double.tryParse(_iqdController.text.trim()) ?? 0.0;

    if (usdAmount <= 0 && iqdAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appState.isRtl 
              ? 'تکایە بڕێک بنووسە بۆ یەکێک لە دراوەکان!' 
              : 'Please enter an amount for at least one currency!'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    final notes = _notesController.text.trim();
    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // Business category is 'sales_revenue', Personal is 'freelance'
    final category = _selectedScope == 'business' ? 'Sales/Revenue' : 'Freelance/Side Hustle';
    final title = appState.isRtl ? 'داهاتی ڕۆژانە - $dateString' : 'Daily Earnings - $dateString';
    final fallbackNotes = notes.isNotEmpty ? notes : (appState.isRtl ? 'داهاتی ڕۆژانە' : 'Daily revenue log');

    // 1. Log USD transaction if present
    if (usdAmount > 0) {
      final txUsd = Transaction(
        id: '${DateTime.now().millisecondsSinceEpoch}_usd',
        title: title,
        amount: usdAmount,
        isIncome: true,
        category: category,
        date: _selectedDate,
        description: fallbackNotes,
        currency: 'USD',
        scope: _selectedScope,
        paymentMethod: 'Cash',
        contact: '',
      );
      appState.addTransaction(txUsd);
    }

    // 2. Log IQD transaction if present
    if (iqdAmount > 0) {
      final txIqd = Transaction(
        id: '${DateTime.now().millisecondsSinceEpoch}_iqd',
        title: title,
        amount: iqdAmount,
        isIncome: true,
        category: category,
        date: _selectedDate,
        description: fallbackNotes,
        currency: 'IQD',
        scope: _selectedScope,
        paymentMethod: 'Cash',
        contact: '',
      );
      appState.addTransaction(txIqd);
    }

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appState.isRtl 
            ? 'داهاتی ڕۆژانە بە سەرکەوتوویی تۆمارکرا!' 
            : 'Daily earnings successfully logged!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Dialog(
      backgroundColor: const Color(0xFF111422),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appState.t('log_daily_earnings'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.6)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                appState.t('daily_earnings_desc'),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 20),

              // Scope selector (Personal vs Business)
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedScope = 'personal'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedScope == 'personal'
                              ? Colors.white.withOpacity(0.08)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedScope == 'personal'
                                ? Colors.white.withOpacity(0.12)
                                : Colors.transparent,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          appState.t('personal'),
                          style: TextStyle(
                            color: _selectedScope == 'personal' ? Colors.white : Colors.white.withOpacity(0.4),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedScope = 'business'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedScope == 'business'
                              ? const Color(0xFF10B981).withOpacity(0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedScope == 'business'
                                ? const Color(0xFF10B981).withOpacity(0.25)
                                : Colors.transparent,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          appState.t('business'),
                          style: TextStyle(
                            color: _selectedScope == 'business' ? const Color(0xFF10B981) : Colors.white.withOpacity(0.4),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // USD amount input
              TextFormField(
                controller: _usdController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: appState.t('usd_received'),
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                  prefixIcon: const Icon(Icons.attach_money_rounded, color: Colors.blueAccent),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.04),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // IQD amount input
              TextFormField(
                controller: _iqdController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: appState.t('iqd_received'),
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                  prefixIcon: const Icon(Icons.monetization_on_rounded, color: Colors.orangeAccent),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.04),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Date selector
              GestureDetector(
                onTap: () => _pickDate(context, appState),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${appState.t('date')}: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Icon(Icons.calendar_today_rounded, color: Colors.white.withOpacity(0.4), size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Notes field
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                textInputAction: TextInputAction.done,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  labelText: appState.t('notes'),
                  hintText: appState.t('daily_sales_notes'),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                  prefixIcon: Icon(Icons.description_rounded, color: Colors.white.withOpacity(0.4)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.04),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: () => _submit(context, appState),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  appState.t('add'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
