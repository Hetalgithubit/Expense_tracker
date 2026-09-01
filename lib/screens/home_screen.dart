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

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final expenseProvider =
    context.watch<
        ExpenseProvider>();

    final userProvider =
    context.watch<UserProvider>();

    final firebaseUser =
        firebase_auth
            .FirebaseAuth
            .instance
            .currentUser;

    final now =
    DateTime.now();

    // ============================================================
    // LOGIN CHECK
    // ============================================================

    if (firebaseUser == null) {
      return const SafeArea(
        child: Center(
          child: Text(
            'Please login first',
          ),
        ),
      );
    }

    // ============================================================
    // IMPORTANT
    //
    // ExpenseProvider already loads expenses only for the
    // currently logged-in Firebase UID.
    //
    // DO NOT FILTER AGAIN BY selectedUser.
    // ============================================================

    final userExpenses =
    List.of(
      expenseProvider.expenses,
    );

    userExpenses.sort(
          (a, b) =>
          b.date.compareTo(
            a.date,
          ),
    );

    // ============================================================
    // EXPENSE ONLY
    // ============================================================

    final expenseOnly =
    userExpenses
        .where(
          (expense) =>
      !expense.isIncome,
    )
        .toList();

    // ============================================================
    // CATEGORY TOTALS
    // ============================================================

    final Map<String, double>
    totals = {};

    for (final expense
    in expenseOnly) {
      totals[expense.category] =
          (totals[expense.category] ??
              0) +
              expense.amount;
    }

    final top =
    totals.entries.toList()
      ..sort(
            (a, b) =>
            b.value.compareTo(
              a.value,
            ),
      );

    // ============================================================
    // HOME
    // ============================================================

    return SafeArea(
      child:
      RefreshIndicator(
        onRefresh: () async {
          await expenseProvider
              .init(
            userId:
            firebaseUser.uid,
          );
        },
        child:
        CustomScrollView(
          slivers: [
            // ==================================================
            // HEADER
            // ==================================================

            SliverPadding(
              padding:
              const EdgeInsets
                  .fromLTRB(
                16,
                12,
                16,
                0,
              ),
              sliver:
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Row(
                      children: [
                        // PROFILE
                        GestureDetector(
                          onTap: () {
                            _showProfileSheet(
                              context,
                              firebaseUser,
                              userProvider
                                  .selectedUser,
                            );
                          },
                          child:
                          CircleAvatar(
                            radius: 24,
                            backgroundColor:
                            AppColors
                                .greenDark,
                            child:
                            Text(
                              _profileInitial(
                                firebaseUser,
                                userProvider
                                    .selectedUser,
                              ),
                              style:
                              const TextStyle(
                                color:
                                AppColors
                                    .green,
                                fontWeight:
                                FontWeight
                                    .w800,
                                fontSize:
                                18,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        // DATE
                        Expanded(
                          child:
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              const Text(
                                'Good Morning',
                                style:
                                TextStyle(
                                  color:
                                  AppColors
                                      .muted,
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Text(
                                '${_monthName(now.month)} ${now.year}',
                                style:
                                const TextStyle(
                                  fontSize:
                                  22,
                                  fontWeight:
                                  FontWeight
                                      .w800,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // NOTIFICATION
                        Container(
                          padding:
                          const EdgeInsets
                              .all(
                            12,
                          ),
                          decoration:
                          BoxDecoration(
                            color: AppColors
                                .greenDark,
                            borderRadius:
                            BorderRadius
                                .circular(
                              12,
                            ),
                          ),
                          child:
                          const Icon(
                            Icons
                                .notifications_none,
                            color:
                            AppColors
                                .text,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    _userCard(
                      firebaseUser,
                      userProvider
                          .selectedUser,
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // BUDGET
            // ==================================================

            SliverPadding(
              padding:
              const EdgeInsets
                  .fromLTRB(
                16,
                18,
                16,
                0,
              ),
              sliver:
              SliverToBoxAdapter(
                child:
                _budgetCard(
                  expenseProvider,
                  userExpenses,
                ),
              ),
            ),

            // ==================================================
            // LATEST TRANSACTION
            // ==================================================

            SliverPadding(
              padding:
              const EdgeInsets
                  .fromLTRB(
                16,
                28,
                16,
                0,
              ),
              sliver:
              SliverToBoxAdapter(
                child:
                userExpenses.isEmpty
                    ? const AppCard(
                  child:
                  Padding(
                    padding:
                    EdgeInsets
                        .all(
                      20,
                    ),
                    child:
                    Center(
                      child:
                      Text(
                        'No transactions yet',
                      ),
                    ),
                  ),
                )
                    : TransactionTile(
                  expense:
                  userExpenses
                      .first,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) =>
                            TransactionDetailsScreen(
                              expenseId:
                              userExpenses
                                  .first
                                  .id,
                            ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ==================================================
            // TOP CATEGORIES TITLE
            // ==================================================

            SliverPadding(
              padding:
              const EdgeInsets
                  .fromLTRB(
                16,
                12,
                16,
                0,
              ),
              sliver:
              SliverToBoxAdapter(
                child:
                SectionTitle(
                  'Top Categories',
                  action:
                  'View all',
                  onAction: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) =>
                        const AllCategoriesScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ==================================================
            // TOP CATEGORIES
            // ==================================================

            SliverPadding(
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 16,
              ),
              sliver:
              SliverToBoxAdapter(
                child: top.isEmpty
                    ? const AppCard(
                  child:
                  Padding(
                    padding:
                    EdgeInsets
                        .all(
                      18,
                    ),
                    child:
                    Center(
                      child:
                      Text(
                        'No category data',
                      ),
                    ),
                  ),
                )
                    : GridView.builder(
                  shrinkWrap:
                  true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  itemCount:
                  top
                      .take(
                    4,
                  )
                      .length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                    2,
                    crossAxisSpacing:
                    10,
                    mainAxisSpacing:
                    10,
                    childAspectRatio:
                    1.25,
                  ),
                  itemBuilder:
                      (
                      _,
                      index,
                      ) {
                    final item =
                    top[index];

                    final info =
                    categoryInfo(
                      item.key,
                    );

                    final max =
                    top.isEmpty
                        ? 1.0
                        : top.first
                        .value;

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
                      const EdgeInsets
                          .all(
                        12,
                      ),
                      decoration:
                      BoxDecoration(
                        color:
                        AppColors
                            .card,
                        borderRadius:
                        BorderRadius
                            .circular(
                          14,
                        ),
                      ),
                      child:
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Text(
                            info.emoji,
                            style:
                            const TextStyle(
                              fontSize:
                              20,
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          Text(
                            item.key,
                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight
                                  .w700,
                            ),
                          ),

                          const SizedBox(
                            height: 3,
                          ),

                          Text(
                            money(
                              item.value,
                            ),
                            style:
                            const TextStyle(
                              color:
                              AppColors
                                  .muted,
                              fontSize:
                              11,
                            ),
                          ),

                          const Spacer(),

                          ProgressLine(
                            value:
                            progress,
                            color:
                            info
                                .color,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // ==================================================
            // RECENT TRANSACTION TITLE
            // ==================================================

            SliverPadding(
              padding:
              const EdgeInsets
                  .fromLTRB(
                16,
                24,
                16,
                8,
              ),
              sliver:
              SliverToBoxAdapter(
                child:
                SectionTitle(
                  'Recent Transaction',
                  action:
                  'View all',
                  onAction: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) =>
                        const AllTransactionsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ==================================================
            // RECENT TRANSACTIONS
            // ==================================================

            SliverPadding(
              padding:
              const EdgeInsets
                  .fromLTRB(
                16,
                0,
                16,
                24,
              ),
              sliver:
              userExpenses.isEmpty
                  ? const SliverToBoxAdapter(
                child:
                AppCard(
                  child:
                  Padding(
                    padding:
                    EdgeInsets
                        .all(
                      20,
                    ),
                    child:
                    Center(
                      child:
                      Text(
                        'No recent transactions',
                      ),
                    ),
                  ),
                ),
              )
                  : SliverList
                  .separated(
                itemCount:
                userExpenses
                    .take(
                  5,
                )
                    .length,
                separatorBuilder:
                    (
                    _,
                    __,
                    ) =>
                const SizedBox(
                  height: 8,
                ),
                itemBuilder:
                    (
                    _,
                    index,
                    ) {
                  final expense =
                  userExpenses[
                  index];

                  return TransactionTile(
                    expense:
                    expense,
                    onTap: () {
                      Navigator
                          .push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
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

  // ============================================================
  // PROFILE INITIAL
  // ============================================================

  String _profileInitial(
      firebase_auth.User?
      firebaseUser,
      dynamic selectedUser,
      ) {
    final name =
        firebaseUser?.displayName ??
            selectedUser?.name ??
            '';

    if (name
        .trim()
        .isNotEmpty) {
      return name
          .trim()
          .substring(0, 1)
          .toUpperCase();
    }

    final email =
        firebaseUser?.email ??
            '';

    if (email.isNotEmpty) {
      return email
          .substring(0, 1)
          .toUpperCase();
    }

    return 'U';
  }

  // ============================================================
  // PROFILE SHEET
  // ============================================================

  void _showProfileSheet(
      BuildContext context,
      firebase_auth.User?
      firebaseUser,
      dynamic selectedUser,
      ) {
    final authProvider =
    context.read<
        AuthProvider>();

    final name =
        firebaseUser?.displayName ??
            selectedUser?.name ??
            'User';

    final email =
        firebaseUser?.email ??
            '';

    showModalBottomSheet(
      context: context,
      backgroundColor:
      AppColors.card,
      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(
            24,
          ),
        ),
      ),
      builder:
          (sheetContext) {
        return SafeArea(
          child: Padding(
            padding:
            const EdgeInsets
                .all(
              24,
            ),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor:
                  AppColors
                      .greenDark,
                  child: Text(
                    _profileInitial(
                      firebaseUser,
                      selectedUser,
                    ),
                    style:
                    const TextStyle(
                      color:
                      AppColors
                          .green,
                      fontSize: 26,
                      fontWeight:
                      FontWeight
                          .w800,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Text(
                  name,
                  style:
                  const TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight
                        .w800,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  email,
                  style:
                  const TextStyle(
                    color:
                    AppColors
                        .muted,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                SizedBox(
                  width:
                  double.infinity,
                  height: 50,
                  child:
                  ElevatedButton.icon(
                    onPressed:
                        () async {
                      Navigator.pop(
                        sheetContext,
                      );

                      await authProvider
                          .logout();
                    },
                    icon:
                    const Icon(
                      Icons.logout,
                    ),
                    label:
                    const Text(
                      'Logout',
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // USER CARD
  // ============================================================

  Widget _userCard(
      firebase_auth.User?
      firebaseUser,
      dynamic selectedUser,
      ) {
    final name =
        firebaseUser?.displayName ??
            selectedUser?.name ??
            'User';

    final email =
        firebaseUser?.email ??
            selectedUser
                ?.mobileNumber ??
            '';

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(
        16,
      ),
      decoration:
      BoxDecoration(
        color:
        AppColors.greenDark,
        borderRadius:
        BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color: AppColors.green
              .withOpacity(
            0.30,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor:
            AppColors.green
                .withOpacity(
              0.15,
            ),
            child: Text(
              _profileInitial(
                firebaseUser,
                selectedUser,
              ),
              style:
              const TextStyle(
                color:
                AppColors.green,
                fontWeight:
                FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                const Text(
                  'Logged In User',
                  style:
                  TextStyle(
                    color:
                    AppColors
                        .muted,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  name,
                  style:
                  const TextStyle(
                    color:
                    AppColors.text,
                    fontSize: 17,
                    fontWeight:
                    FontWeight
                        .w800,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  email,
                  style:
                  const TextStyle(
                    color:
                    AppColors
                        .muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.check_circle,
            color:
            AppColors.green,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUDGET CARD
  // ============================================================

  Widget _budgetCard(
      ExpenseProvider provider,
      List userExpenses,
      ) {
    final now =
    DateTime.now();

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
        : (monthlySpent /
        budget)
        .clamp(
      0.0,
      1.0,
    )
        .toDouble();

    final remaining =
        budget -
            monthlySpent;

    return AppCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'This Month',
                  style:
                  TextStyle(
                    color:
                    AppColors
                        .muted,
                  ),
                ),
              ),
              Text(
                '${(percent * 100).round()}%',
                style:
                const TextStyle(
                  color:
                  AppColors
                      .green,
                  fontWeight:
                  FontWeight
                      .w700,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            money(
              monthlySpent,
            ),
            style:
            const TextStyle(
              fontSize: 26,
              fontWeight:
              FontWeight
                  .w800,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            'of ${money(budget)} budget',
            style:
            const TextStyle(
              color:
              AppColors.muted,
              fontSize: 11,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          ProgressLine(
            value: percent,
            color:
            AppColors.green,
          ),

          const SizedBox(
            height: 12,
          ),

          const Text(
            'REMAINING',
            style:
            TextStyle(
              color:
              AppColors.muted,
              fontSize: 10,
              fontWeight:
              FontWeight
                  .w700,
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          Text(
            money(
              remaining,
            ),
            style:
            const TextStyle(
              color:
              AppColors.green,
              fontSize: 18,
              fontWeight:
              FontWeight
                  .w800,
            ),
          ),

          if (monthlyIncome > 0) ...[
            const SizedBox(
              height: 5,
            ),
            Text(
              'Income: ${money(monthlyIncome)}',
              style:
              const TextStyle(
                color:
                AppColors
                    .muted,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // MONTH NAME
  // ============================================================

  String _monthName(
      int month,
      ) {
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