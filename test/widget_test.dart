import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:salary_flow/main.dart';
import 'package:salary_flow/services/storage_service.dart';
import 'package:salary_flow/state/app_state.dart';

void main() {
  testWidgets('SalaryFlow smoke test', (WidgetTester tester) async {
    // Set up mock SharedPreferences for test environment
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.init();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(storageService),
        child: const SalaryFlowApp(),
      ),
    );

    // Verify dashboard renders the welcome header
    expect(find.text('WELCOME BACK'), findsOneWidget);
  });
}
