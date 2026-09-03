import 'package:firebase_auth/firebase_auth.dart'
as firebase_auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';
import '../widgets/transaction_tile.dart';
import 'all_categories_screen.dart';
import 'all_transactions_screen.dart';
import 'transaction_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final expenseProvider =
    context.watch<ExpenseProvider>();

    final userProvider =
    context.watch<UserProvider>();

    final firebaseUser =
        firebase_auth.FirebaseAuth.instance.currentUser;

    final selectedUser =
        userProvider.selectedUser;

    final now = DateTime.now();

    final firebaseUid = firebaseUser?.uid;

    final List<Expense> userExpenses =
    firebaseUid == null
        ? <Expense>[]
        : expenseProvider.expenses
        .where(
          (expense) =>
      expense.userId == firebaseUid,
    )
        .toList();

    userExpenses.sort(
          (a, b) => b.date.compareTo(a.date),
    );

    final List<Expense> expenseOnly =
    userExpenses
        .where(
          (expense) => !expense.isIncome,
    )
        .toList();

    final Map<String, double> categoryTotals = {};

    for (final expense in expenseOnly) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) +
              expense.amount;
    }

    final topCategories =
    categoryTotals.entries.toList()
      ..sort(
            (a, b) =>
            b.value.compareTo(a.value),
      );

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showProfileSheet(
                            context,
                            firebaseUser,
                            selectedUser,
                          );
                        },
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor:
                          AppColors.greenDark,
                          child: Text(
                            _profileInitial(
                              firebaseUser,
                              selectedUser,
                            ),
                            style: const TextStyle(
                              color: AppColors.green,
                              fontWeight:
                              FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Good Morning',
                              style: TextStyle(
                                color: AppColors.muted,
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              '${_monthName(now.month)} ${now.year}',
                              style:
                              const TextStyle(
                                fontSize: 21,
                                fontWeight:
                                FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding:
                        const EdgeInsets.all(12),
                        decoration:
                        BoxDecoration(
                          color:
                          AppColors.blue,
                          borderRadius:
                          BorderRadius.circular(
                            12,
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_none,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _userCard(
                    selectedUser,
                    firebaseUser,
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: _budgetCard(
                expenseProvider,
                userExpenses,
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: _todaySpentCard(
                expenseOnly,
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              16,
              28,
              16,
              8,
            ),
            sliver: SliverToBoxAdapter(
              child: SectionTitle(
                'Top Categories',
                action: 'View all',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const AllCategoriesScreen(),
                    ),
                  );
                },
              ),
            ),
          ),

          SliverPadding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            sliver: SliverToBoxAdapter(
              child: topCategories.isEmpty
                  ? const AppCard(
                child: Padding(
                  padding:
                  EdgeInsets.all(18),
                  child: Center(
                    child: Text(
                      'No category data',
                    ),
                  ),
                ),
              )
                  : GridView.builder(
                shrinkWrap: true,
                physics:
                const NeverScrollableScrollPhysics(),
                itemCount:
                topCategories
                    .take(4)
                    .length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.25,
                ),
                itemBuilder:
                    (_, index) {
                  final item =
                  topCategories[index];

                  final info =
                  categoryInfo(
                    item.key,
                  );

                  final maxValue =
                  topCategories
                      .isEmpty
                      ? 1.0
                      : topCategories
                      .first
                      .value;

                  final progress =
                  maxValue <= 0
                      ? 0.0
                      : (item.value /
                      maxValue)
                      .clamp(
                    0.0,
                    1.0,
                  )
                      .toDouble();

                  return Container(
                    padding:
                    const EdgeInsets.all(
                      12,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      AppColors.card,
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          info.emoji,
                          style:
                          const TextStyle(
                            fontSize: 20,
                          ),
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        Text(
                          item.key,
                          maxLines: 1,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        Text(
                          money(item.value),
                          style:
                          const TextStyle(
                            color:
                            AppColors.muted,
                            fontSize: 11,
                          ),
                        ),

                        const Spacer(),

                        ProgressLine(
                          value: progress,
                          color: info.color,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),



          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              16,
              28,
              16,
              8,
            ),
            sliver: SliverToBoxAdapter(
              child: SectionTitle(
                'Recent Transactions',
                action: 'View all',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const AllTransactionsScreen(),
                    ),
                  );
                },
              ),
            ),
          ),


          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              30,
            ),
            sliver: userExpenses.isEmpty
                ? const SliverToBoxAdapter(
              child: SizedBox.shrink(),
            )
                : SliverList.separated(
              itemCount:
              userExpenses
                  .take(5)
                  .length,
              separatorBuilder:
                  (_, __) =>
              const SizedBox(
                height: 8,
              ),
              itemBuilder:
                  (_, index) {
                final expense =
                userExpenses[index];

                return TransactionTile(
                  expense: expense,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TransactionDetailsScreen(
                              expenseId:
                              expense.id,
                            ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }



  Widget _todaySpentCard(
      List<Expense> expenses) {
    final now = DateTime.now();

    final todayExpenses =
    expenses.where((expense) {
      return expense.date.year == now.year &&
          expense.date.month == now.month &&
          expense.date.day == now.day;
    }).toList();

    final todaySpent =
    todayExpenses.fold<double>(
      0,
          (sum, expense) =>
      sum + expense.amount,
    );

    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  '${now.day} ${_monthName(now.month)} ${now.year}',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  money(todaySpent),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Today's Spent",
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.greenDark,
              borderRadius:
              BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.green,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }



  String _profileInitial(
      firebase_auth.User? firebaseUser,
      dynamic selectedUser) {
    final name =
        firebaseUser?.displayName ??
            selectedUser?.name ??
            '';

    if (name.trim().isNotEmpty) {
      return name
          .trim()
          .substring(0, 1)
          .toUpperCase();
    }

    final email =
        firebaseUser?.email ?? '';

    if (email.isNotEmpty) {
      return email
          .substring(0, 1)
          .toUpperCase();
    }

    return 'U';
  }



  void _showProfileSheet(
      BuildContext context,
      firebase_auth.User? firebaseUser,
      dynamic selectedUser) {
    final authProvider =
    context.read<AuthProvider>();

    final name =
        firebaseUser?.displayName ??
            selectedUser?.name ??
            'User';

    final email =
        firebaseUser?.email ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor:
      AppColors.card,
      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding:
            const EdgeInsets.all(24),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor:
                  AppColors.greenDark,
                  child: Text(
                    _profileInitial(
                      firebaseUser,
                      selectedUser,
                    ),
                    style:
                    const TextStyle(
                      color:
                      AppColors.green,
                      fontSize: 26,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  email,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child:
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(
                        sheetContext,
                      );

                      context
                          .read<
                          ExpenseProvider>()
                          .clearUser();

                      await authProvider
                          .logout();
                    },
                    icon: const Icon(
                      Icons.logout,
                    ),
                    label: const Text(
                      'Logout',
                    ),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _userCard(
      dynamic selectedUser,
      firebase_auth.User? firebaseUser) {
    if (firebaseUser == null) {
      return Container(
        width: double.infinity,
        padding:
        const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(
            alpha: 0.08,
          ),
          borderRadius:
          BorderRadius.circular(14),
          border: Border.all(
            color: Colors.red.withValues(
              alpha: 0.25,
            ),
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.person_off,
              color: Colors.redAccent,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Please login to view your expenses',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final name =
        firebaseUser.displayName ??
            selectedUser?.name ??
            'User';

    final email =
        firebaseUser.email ??
            selectedUser?.mobileNumber ??
            '';

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.greenDark,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.green
              .withValues(
            alpha: 0.30,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor:
            AppColors.green
                .withValues(
              alpha: 0.15,
            ),
            child: Text(
              _profileInitial(
                firebaseUser,
                selectedUser,
              ),
              style:
              const TextStyle(
                color: AppColors.green,
                fontSize: 20,
                fontWeight:
                FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Logged In User',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  name,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    color: AppColors.text,
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  email,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.check_circle,
            color: AppColors.green,
          ),
        ],
      ),
    );
  }



  Widget _budgetCard(
      ExpenseProvider provider,
      List<Expense> userExpenses) {
    final now = DateTime.now();

    final monthlyExpenses =
    userExpenses.where((expense) {
      return !expense.isIncome &&
          expense.date.year == now.year &&
          expense.date.month == now.month;
    }).toList();

    final monthlySpent =
    monthlyExpenses.fold<double>(
      0,
          (sum, expense) =>
      sum + expense.amount,
    );

    final monthlyIncome =
    userExpenses.where((expense) {
      return expense.isIncome &&
          expense.date.year == now.year &&
          expense.date.month == now.month;
    }).fold<double>(
      0,
          (sum, expense) =>
      sum + expense.amount,
    );

    final budget =
        provider.budget.monthly;

    final percent =
    budget <= 0
        ? 0.0
        : (monthlySpent / budget)
        .clamp(
      0.0,
      1.0,
    )
        .toDouble();

    final remaining =
        budget - monthlySpent;

    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'This Month',
                  style: TextStyle(
                    color: AppColors.muted,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  money(monthlySpent),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'of ${money(budget)} budget',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'REMAINING',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  money(remaining),
                  style: const TextStyle(
                    color: AppColors.green,
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                if (monthlyIncome > 0) ...[
                  const SizedBox(height: 5),
                  Text(
                    'Income: ${money(monthlyIncome)}',
                    style:
                    const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 16),

          SizedBox(
            width: 92,
            height: 92,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 86,
                  height: 86,
                  child:
                  CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 9,
                    backgroundColor:
                    AppColors.greenDark,
                    valueColor:
                    const AlwaysStoppedAnimation<
                        Color>(
                      AppColors.green,
                    ),
                  ),
                ),

                Text(
                  '${(percent * 100).round()}%',
                  style:
                  const TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  String _monthName(int month) {
    return const [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ][month - 1];
  }
}