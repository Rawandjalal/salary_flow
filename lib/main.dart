import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/storage_service.dart';
import 'state/app_state.dart';
import 'pages/dashboard_page.dart';
import 'pages/transactions_page.dart';
import 'pages/analysis_page.dart';
import 'pages/settings_page.dart';

import 'pages/planners_page.dart';
import 'widgets/add_transaction_sheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await StorageService.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(storageService),
      child: const SalaryFlowApp(),
    ),
  );
}

class SalaryFlowApp extends StatelessWidget {
  const SalaryFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SalaryFlow',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0D9488),
          secondary: Color(0xFF0284C7),
          surface: Colors.white,
          onSurface: const Color(0xFF0F172A),
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0D9488),
          secondary: Color(0xFF38BDF8),
          surface: const Color(0xFF1E293B),
          onSurface: Colors.white,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  String _getNavLabel(int index, bool isRtl) {
    if (isRtl) {
      switch (index) {
        case 0:
          return 'سەرەکی';
        case 1:
          return 'تۆمارەکان';
        case 2:
          return 'پلانەکان';
        case 3:
          return 'شیکاری';
        case 4:
          return 'ڕێکخستنەکان';
      }
    } else {
      switch (index) {
        case 0:
          return 'Home';
        case 1:
          return 'History';
        case 2:
          return 'Planners';
        case 3:
          return 'Analysis';
        case 4:
          return 'Settings';
      }
    }
    return '';
  }

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

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isRtl = appState.isRtl;

    final List<Widget> pages = [
      DashboardPage(
        onViewAllTransactions: () {
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      const TransactionsPage(),
      const PlannersPage(),
      const AnalysisPage(),
      const SettingsPage(),
    ];

    // GestureDetector handles global keyboard dismissal when tapping background
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          extendBody: true,
          body: pages[_currentIndex],
          bottomNavigationBar: _buildFloatingNavBar(context, isRtl),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 76.0), // push above the floating navbar
            child: FloatingActionButton(
              onPressed: () => _showAddTransaction(context),
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.add_rounded, size: 28),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingNavBar(BuildContext context, bool isRtl) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFF111422).withOpacity(0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.grid_view_rounded, _getNavLabel(0, isRtl)),
                  _buildNavItem(1, Icons.receipt_long_rounded, _getNavLabel(1, isRtl)),
                  _buildNavItem(2, Icons.next_plan_rounded, _getNavLabel(2, isRtl)),
                  _buildNavItem(3, Icons.analytics_rounded, _getNavLabel(3, isRtl)),
                  _buildNavItem(4, Icons.settings_rounded, _getNavLabel(4, isRtl)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final activeColor = const Color(0xFF10B981);

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : Colors.white.withOpacity(0.4),
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: activeColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: -0.2,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
