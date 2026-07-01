import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/transaction_tile.dart';
import 'excel_builder_page.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Income', 'Expense'
  String _selectedCategory = 'All';

  final List<String> _allCategories = [
    'All',
    'Food',
    'Transport',
    'Rent',
    'Entertainment',
    'Shopping',
    'Utilities',
    'Salary',
    'Other'
  ];

  String _getFilterTranslation(BuildContext context, String filter) {
    final appState = Provider.of<AppState>(context, listen: false);
    if (filter == 'All') return appState.isRtl ? 'هەموو' : 'All';
    if (filter == 'Income') return appState.t('income');
    return appState.t('expense');
  }

  String _getCategoryTranslation(BuildContext context, String category) {
    final appState = Provider.of<AppState>(context, listen: false);
    if (category == 'All') return appState.isRtl ? 'هەموو' : 'All';
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

  void _copyCsvReport(BuildContext context, AppState appState) {
    final csvData = appState.exportToCsv();
    Clipboard.setData(ClipboardData(text: csvData));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appState.t('copied')),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final filteredTransactions = appState.transactions.where((tx) {
      final matchesSearch = tx.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _selectedFilter == 'All' ||
          (_selectedFilter == 'Income' && tx.isIncome) ||
          (_selectedFilter == 'Expense' && !tx.isIncome);
      final matchesCategory = _selectedCategory == 'All' || tx.category == _selectedCategory;

      return matchesSearch && matchesType && matchesCategory;
    }).toList();

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Header & CSV Export Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appState.t('recent_transactions'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.table_chart_rounded, color: Color(0xFF10B981), size: 24),
                      tooltip: appState.t('excel_wizard'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ExcelBuilderPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: appState.isRtl ? 'گەڕان بۆ مامەڵەکان...' : 'Search transactions...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.3)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              // Filter Tabs (All / Income / Expense)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    _buildFilterTab('All'),
                    const SizedBox(width: 8),
                    _buildFilterTab('Income'),
                    const SizedBox(width: 8),
                    _buildFilterTab('Expense'),
                  ],
                ),
              ),

              // Categories List (Horizontal Scroll)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _allCategories.length,
                    itemBuilder: (context, index) {
                      final category = _allCategories[index];
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF10B981)
                                : Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF10B981).withOpacity(0.5)
                                  : Colors.white.withOpacity(0.06),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _getCategoryTranslation(context, category),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Transaction List
              Expanded(
                child: filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: Colors.white.withOpacity(0.15),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              appState.isRtl ? 'هیچ ئەنجامێک نەدۆزرایەوە' : 'No matching transactions',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.35),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final tx = filteredTransactions[index];
                          return TransactionTile(
                            transaction: tx,
                            onDelete: () => appState.deleteTransaction(tx.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTab(String type) {
    final isSelected = _selectedFilter == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = type;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? Colors.white.withOpacity(0.12) : Colors.transparent,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            _getFilterTranslation(context, type),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
