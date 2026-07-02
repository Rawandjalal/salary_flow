import 'package:flutter/material.dart';
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
  String _selectedScopeFilter = 'All'; // 'All', 'Personal', 'Business'
  String _selectedCategory = 'All';

  final List<String> _allCategories = [
    'All',
    // Personal
    'Food',
    'Transport',
    'Rent',
    'Entertainment',
    'Shopping',
    'Utilities',
    'Medical',
    'Education',
    'Gift',
    // Business
    'Inventory/Stock',
    'Rent/Office',
    'Marketing/Ads',
    'Salaries/Wages',
    'Software/Tools',
    'Logistics/Shipping',
    'Taxes/Fees',
    'Office Supplies',
    'Sales/Revenue',
    'Service/Consulting',
    'Capital Deposit',
    'Refund/Return',
    'Other'
  ];

  String _getFilterTranslation(BuildContext context, String filter) {
    final appState = Provider.of<AppState>(context, listen: false);
    if (filter == 'All') return appState.isRtl ? 'هەموو' : 'All';
    if (filter == 'Income') return appState.t('income');
    return appState.t('expense');
  }

  String _getScopeTranslation(BuildContext context, String scope) {
    final appState = Provider.of<AppState>(context, listen: false);
    if (scope == 'All') return appState.isRtl ? 'هەموو بوارەکان' : 'All Scopes';
    if (scope == 'Personal') return appState.t('personal');
    return appState.t('business');
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
      case 'Medical':
        return appState.t('medical');
      case 'Education':
        return appState.t('education');
      case 'Gift':
        return appState.t('gift');
      case 'Freelance/Side Hustle':
        return appState.t('freelance');
      case 'Investments':
        return appState.t('investments');
      case 'Inventory/Stock':
        return appState.t('inventory');
      case 'Rent/Office':
        return appState.isRtl ? 'کرێ/پسوولە' : 'Rent / Office';
      case 'Marketing/Ads':
        return appState.t('marketing');
      case 'Salaries/Wages':
        return appState.t('salaries');
      case 'Software/Tools':
        return appState.t('software');
      case 'Logistics/Shipping':
        return appState.t('logistics');
      case 'Taxes/Fees':
        return appState.t('taxes');
      case 'Office Supplies':
        return appState.t('office_supplies');
      case 'Sales/Revenue':
        return appState.t('sales_revenue');
      case 'Service/Consulting':
        return appState.t('service_consulting');
      case 'Capital Deposit':
        return appState.t('capital');
      case 'Refund/Return':
        return appState.t('refund');
      default:
        return appState.t('other');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // Query filters run against appState.allTransactions for historical queries
    final filteredTransactions = appState.allTransactions.where((tx) {
      final matchesSearch = tx.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tx.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tx.contact.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tx.category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesType = _selectedFilter == 'All' ||
          (_selectedFilter == 'Income' && tx.isIncome) ||
          (_selectedFilter == 'Expense' && !tx.isIncome);

      final matchesCategory = _selectedCategory == 'All' || tx.category == _selectedCategory;

      final matchesScope = _selectedScopeFilter == 'All' ||
          tx.scope.toLowerCase() == _selectedScopeFilter.toLowerCase();

      return matchesSearch && matchesType && matchesCategory && matchesScope;
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: appState.isRtl ? 'گەڕان (ناونیشان، لایەن، تێبینی)...' : 'Search (title, contact, notes)...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13.5),
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

              // Scope Filter Tabs (All Scopes / Personal / Business)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    _buildScopeTab('All'),
                    const SizedBox(width: 8),
                    _buildScopeTab('Personal'),
                    const SizedBox(width: 8),
                    _buildScopeTab('Business'),
                  ],
                ),
              ),

              // Filter Tabs (All / Income / Expense)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
                padding: const EdgeInsets.symmetric(vertical: 6),
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
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 6),

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
          padding: const EdgeInsets.symmetric(vertical: 10),
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
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScopeTab(String scope) {
    final isSelected = _selectedScopeFilter == scope;
    final isBusiness = scope == 'Business';
    Color activeBg = Colors.white.withOpacity(0.08);
    Color activeText = Colors.white;
    if (isSelected) {
      if (isBusiness) {
        activeBg = const Color(0xFF10B981).withOpacity(0.12);
        activeText = const Color(0xFF10B981);
      }
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedScopeFilter = scope;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected 
                  ? (isBusiness ? const Color(0xFF10B981).withOpacity(0.25) : Colors.white.withOpacity(0.12))
                  : Colors.transparent,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            _getScopeTranslation(context, scope),
            style: TextStyle(
              color: isSelected ? activeText : Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
