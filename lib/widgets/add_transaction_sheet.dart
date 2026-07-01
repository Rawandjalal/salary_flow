import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/transaction.dart';

class AddTransactionSheet extends StatefulWidget {
  final Function(Transaction) onAdd;

  const AddTransactionSheet({super.key, required this.onAdd});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isIncome = false;
  String _selectedCurrency = 'USD'; // Parallel currency selection
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();

  final List<String> _expenseCategories = [
    'Food',
    'Transport',
    'Rent',
    'Entertainment',
    'Shopping',
    'Utilities',
    'Other'
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Other'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) return;

    final newTx = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      amount: amount,
      isIncome: _isIncome,
      category: _selectedCategory,
      date: _selectedDate,
      description: _descriptionController.text.trim(),
      currency: _selectedCurrency, // Multi-currency support
    );

    widget.onAdd(newTx);
    Navigator.of(context).pop();
  }

  Future<void> _pickDate(AppState appState) async {
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

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final categories = _isIncome ? _incomeCategories : _expenseCategories;
    final displaySymbol = _selectedCurrency == 'USD' ? '\$' : 'د.ع';

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111422),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appState.t('new_transaction'),
                    style: const TextStyle(
                      fontSize: 20,
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
              const SizedBox(height: 16),

              // Segmented Currency Selector (USD vs IQD)
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCurrency = 'USD';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedCurrency == 'USD'
                              ? Colors.white.withOpacity(0.08)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedCurrency == 'USD'
                                ? Colors.white.withOpacity(0.12)
                                : Colors.transparent,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '\$ ',
                              style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'USD',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCurrency = 'IQD';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedCurrency == 'IQD'
                              ? Colors.white.withOpacity(0.08)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedCurrency == 'IQD'
                                ? Colors.white.withOpacity(0.12)
                                : Colors.transparent,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'د.ع ',
                              style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              'IQD',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Segmented Type Selector (Expense vs Income)
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isIncome = false;
                          _selectedCategory = 'Food';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isIncome
                              ? Colors.white.withOpacity(0.08)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: !_isIncome
                                ? Colors.white.withOpacity(0.12)
                                : Colors.transparent,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          appState.t('expense'),
                          style: TextStyle(
                            color: !_isIncome ? Colors.white : Colors.white.withOpacity(0.4),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isIncome = true;
                          _selectedCategory = 'Salary';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isIncome
                              ? const Color(0xFF10B981).withOpacity(0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _isIncome
                                ? const Color(0xFF10B981).withOpacity(0.25)
                                : Colors.transparent,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          appState.t('income'),
                          style: TextStyle(
                            color: _isIncome ? const Color(0xFF10B981) : Colors.white.withOpacity(0.4),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title Input
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: appState.t('title'),
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                  prefixIcon: Icon(Icons.edit_note_rounded, color: Colors.white.withOpacity(0.4)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.5),
                  ),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? (appState.isRtl ? 'تکایە ناونیشان بنووسە' : 'Please enter a title') : null,
              ),
              const SizedBox(height: 14),

              // Amount Input
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  labelText: '${appState.t('amount')} ($displaySymbol)',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                  prefixIcon: Icon(Icons.attach_money_rounded, color: Colors.white.withOpacity(0.4)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return (appState.isRtl ? 'تکایە بڕ بنووسە' : 'Please enter an amount');
                  final parsed = double.tryParse(val);
                  if (parsed == null || parsed <= 0) return (appState.isRtl ? 'ژمارەیەکی دروست بنووسە' : 'Please enter a valid amount');
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Description (Why) Input
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  labelText: appState.t('reason'),
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                  prefixIcon: Icon(Icons.description_rounded, color: Colors.white.withOpacity(0.4)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Category & Date Selection
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      dropdownColor: const Color(0xFF161B2E),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        labelText: appState.t('category'),
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(
                            cat == 'Salary'
                                ? appState.t('salary')
                                : cat == 'Food'
                                    ? appState.t('food')
                                    : cat == 'Transport'
                                        ? appState.t('transport')
                                        : cat == 'Rent'
                                            ? appState.t('rent')
                                            : cat == 'Entertainment'
                                                ? appState.t('entertainment')
                                                : cat == 'Shopping'
                                                    ? appState.t('shopping')
                                                    : cat == 'Utilities'
                                                        ? appState.t('utilities')
                                                        : appState.t('other'),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCategory = val;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDate(appState),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MMM dd, yyyy').format(_selectedDate),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Icon(Icons.calendar_today_rounded, color: Colors.white.withOpacity(0.4), size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Submit Button
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isIncome ? const Color(0xFF10B981) : Colors.white,
                  foregroundColor: _isIncome ? Colors.white : const Color(0xFF111422),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  appState.t('add_transaction'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
