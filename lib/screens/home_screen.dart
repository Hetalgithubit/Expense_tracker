import 'package:firebase_auth/firebase_auth.dart'
as firebase_auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
import '../services/notification_service.dart';


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
        firebase_auth.FirebaseAuth
            .instance.currentUser;

    final now = DateTime.now();

    if (firebaseUser == null) {
      return const SafeArea(
        child: Center(
          child: Text(
            'Please login first',
          ),
        ),
      );
    }

    final userExpenses =
    List.of(expenseProvider.expenses);

    userExpenses.sort(
          (a, b) => b.date.compareTo(a.date),
    );

    final expenseOnly =
    userExpenses
        .where(
          (expense) => !expense.isIncome,
    )
        .toList();

    final Map<String, double> totals = {};

    for (final expense in expenseOnly) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) +
              expense.amount;
    }

    final top =
    totals.entries.toList()
      ..sort(
            (a, b) =>
            b.value.compareTo(a.value),
      );

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await expenseProvider.init(
            userId: firebaseUser.uid,
          );
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                24,
                18,
                24,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showProfileSheet(
                          context,
                          firebaseUser,
                          userProvider.selectedUser,
                        );
                      },
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor:
                        AppColors.greenDark,
                        child: Text(
                          _profileInitial(
                            firebaseUser,
                            userProvider.selectedUser,
                          ),
                          style: const TextStyle(
                            color: AppColors.green,
                            fontSize: 19,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Good Morning',
                            style: TextStyle(
                              color:
                              AppColors.muted,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${_monthName(now.month)} ${now.year}',
                            style: const TextStyle(
                              fontSize: 27,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color:
                        AppColors.greenDark,
                        borderRadius:
                        BorderRadius.circular(
                          17,
                        ),
                      ),
                      child: const Icon(
                        Icons.notifications_none,
                        color: AppColors.text,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                24,
                22,
                24,
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
                24,
                22,
                24,
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
                24,
                28,
                24,
                12,
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
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              sliver: SliverToBoxAdapter(
                child: top.isEmpty
                    ? const AppCard(
                  child: Padding(
                    padding:
                    EdgeInsets.all(20),
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
                  top.take(4).length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.12,
                  ),
                  itemBuilder:
                      (_, index) {
                    final item =
                    top[index];

                    final info =
                    categoryInfo(
                      item.key,
                    );

                    final max =
                        top.first.value;

                    final progress =
                    max <= 0
                        ? 0.0
                        : (item.value /
                        max)
                        .clamp(
                      0.0,
                      1.0,
                    )
                        .toDouble();

                    return Container(
                      padding:
                      const EdgeInsets.all(
                        14,
                      ),
                      decoration:
                      BoxDecoration(
                        color:
                        AppColors.card,
                        borderRadius:
                        BorderRadius.circular(
                          16,
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
                              fontSize: 23,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            item.key,
                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            const TextStyle(
                              fontSize: 15,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            money(item.value),
                            style:
                            const TextStyle(
                              color:
                              AppColors
                                  .muted,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          ProgressLine(
                            value: progress,
                            color:
                            info.color,
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
                24,
                28,
                24,
                10,
              ),
              sliver: SliverToBoxAdapter(
                child: SectionTitle(
                  'Recent Transaction',
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
                24,
                0,
                24,
                30,
              ),
              sliver: userExpenses.isEmpty
                  ? const SliverToBoxAdapter(
                child: AppCard(
                  child: Padding(
                    padding:
                    EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'No recent transactions',
                      ),
                    ),
                  ),
                ),
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
      ),
    );
  }

  Widget _todaySpentCard(
      List expenses,
      ) {
    final now = DateTime.now();

    final todayExpenses =
    expenses.where(
          (expense) {
        return expense.date.year ==
            now.year &&
            expense.date.month ==
                now.month &&
            expense.date.day ==
                now.day;
      },
    ).toList();

    final todaySpent =
    todayExpenses.fold<double>(
      0,
          (sum, expense) =>
      sum + expense.amount,
    );

    return Container(
      height: 108,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.card,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
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
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Text(
                  '${now.day} ${_monthName(now.month)} ${now.year}',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  money(todaySpent),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Today's Spent",
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.nightlight_round,
            color: Colors.blueAccent,
            size: 25,
          ),
        ],
      ),
    );
  }

  Widget _budgetCard(
      ExpenseProvider provider,
      List userExpenses,
      ) {
    final now = DateTime.now();

    final monthlyExpenses =
    userExpenses.where(
          (expense) {
        return !expense.isIncome &&
            expense.date.year ==
                now.year &&
            expense.date.month ==
                now.month;
      },
    ).toList();

    final monthlyIncome =
    userExpenses.where(
          (expense) {
        return expense.isIncome &&
            expense.date.year ==
                now.year &&
            expense.date.month ==
                now.month;
      },
    ).fold<double>(
      0,
          (sum, expense) =>
      sum + expense.amount,
    );

    final monthlySpent =
    monthlyExpenses.fold<double>(
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
        .clamp(0.0, 1.0)
        .toDouble();

    final remaining =
        budget - monthlySpent;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'This Month',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 15,
                  ),
                ),
              ),
              SizedBox(
                width: 86,
                height: 86,
                child: Stack(
                  alignment:
                  Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: 1,
                      color:
                      AppColors.greenDark,
                      strokeWidth: 8,
                    ),
                    CircularProgressIndicator(
                      value: percent,
                      color:
                      AppColors.green,
                      strokeWidth: 8,
                    ),
                    Text(
                      '${(percent * 100).round()}%',
                      style:
                      const TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            money(monthlySpent),
            style: const TextStyle(
              fontSize: 30,
              fontWeight:
              FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'of ${money(budget)} budget',
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 15),
          ProgressLine(
            value: percent,
            color: AppColors.green,
          ),
          const SizedBox(height: 15),
          const Text(
            'REMAINING',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight:
              FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            money(remaining),
            style: const TextStyle(
              color: AppColors.green,
              fontSize: 20,
              fontWeight:
              FontWeight.w800,
            ),
          ),
          if (monthlyIncome > 0) ...[
            const SizedBox(height: 5),
            Text(
              'Income: ${money(monthlyIncome)}',
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _profileInitial(
      firebase_auth.User? firebaseUser,
      dynamic selectedUser,
      ) {
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
      dynamic selectedUser,
      ) {
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
                      color: AppColors.green,
                      fontSize: 26,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style:
                  const TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  style:
                  const TextStyle(
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