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
    final appState = Provider.of<AppState>(context, listen: false);

    return MaterialApp(
      title: 'SalaryFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF07080F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981),
          secondary: Color(0xFF0D9488),
          surface: Color(0xFF111422),
          onSurface: Colors.white,
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.dark().textTheme,
        ),
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
          return 'شیکاری';
        case 3:
          return 'ڕێکخستنەکان';
      }
    } else {
      switch (index) {
        case 0:
          return 'Home';
        case 1:
          return 'History';
        case 2:
          return 'Analysis';
        case 3:
          return 'Settings';
      }
    }
    return '';
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
      const AnalysisPage(),
      const SettingsPage(),
    ];

    // Directionality dynamically toggles TextDirection at layout root
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        extendBody: true,
        body: pages[_currentIndex],
        bottomNavigationBar: _buildFloatingNavBar(context, isRtl),
      ),
    );
  }

  Widget _buildFloatingNavBar(BuildContext context, bool isRtl) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
                  _buildNavItem(2, Icons.analytics_rounded, _getNavLabel(2, isRtl)),
                  _buildNavItem(3, Icons.settings_rounded, _getNavLabel(3, isRtl)),
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
