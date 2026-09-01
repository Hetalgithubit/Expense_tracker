import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'add_expense_screen.dart';
import 'analytics_screen.dart';
import 'budget_screen.dart';
import 'home_screen.dart';


class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
  });

  @override
  State<MainShell> createState() =>
      _MainShellState();
}

class _MainShellState
    extends State<MainShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),
      const AnalyticsScreen(),
      AddExpenseScreen(),
      const BudgetScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.black,
        indicatorColor: Colors.transparent,
        selectedIndex: index,
        onDestinationSelected: (value) {
          setState(() {
            index = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
              color: AppColors.green,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.analytics_outlined,
            ),
            selectedIcon: Icon(
              Icons.analytics,
              color: AppColors.green,
            ),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.note_add_outlined,
            ),
            selectedIcon: Icon(
              Icons.note_add,
              color: AppColors.green,
            ),
            label: 'Add',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.account_balance_wallet_outlined,
            ),
            selectedIcon: Icon(
              Icons.account_balance_wallet,
              color: AppColors.green,
            ),
            label: 'Budget',
          ),
        ],
      ),
    );
  }
}