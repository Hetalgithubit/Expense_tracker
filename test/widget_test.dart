import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/providers/user_provider.dart';
import 'package:expense_tracker/main.dart';

void main() {
  testWidgets('Expense Tracker app loads', (tester) async {
    final authProvider = AuthProvider();
    final userProvider = UserProvider();
    final expenseProvider = ExpenseProvider();

    await tester.pumpWidget(
      ExpenseTrackerApp(
        authProvider: authProvider,
        userProvider: userProvider,
        expenseProvider: expenseProvider,
      ),
    );

    expect(find.text('Expense Tracker'), findsOneWidget);
  });
}