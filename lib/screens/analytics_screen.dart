import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/category_breakdown.dart';
import '../widgets/common_widgets.dart';
import 'custom_report_screen.dart';
import 'weekly_report_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({
    super.key,
  });

  @override
  State<AnalyticsScreen> createState() =>
      _AnalyticsScreenState();
}

class _AnalyticsScreenState
    extends State<AnalyticsScreen> {
  String period = 'This Week';

  DateTimeRange get range {
    final now = DateTime.now();

    if (period == 'This Month') {
      return DateTimeRange(
        start: DateTime(
          now.year,
          now.month,
          1,
        ),
        end: DateTime(
          now.year,
          now.month + 1,
          0,
          23,
          59,
          59,
        ),
      );
    }

    if (period == 'This Year') {
      return DateTimeRange(
        start: DateTime(
          now.year,
          1,
          1,
        ),
        end: DateTime(
          now.year,
          12,
          31,
          23,
          59,
          59,
        ),
      );
    }

    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(
      Duration(
        days: now.weekday - 1,
      ),
    );

    final end = DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
    );

    return DateTimeRange(
      start: start,
      end: end,
    );
  }

  List<Expense> _filteredExpenses(
      List<Expense> expenses,
      String userId,
      ) {
    final currentRange = range;

    return expenses.where(
          (expense) {
        final belongsToUser =
            expense.userId == userId;

        final isInRange =
            !expense.date
                .isBefore(
              currentRange.start,
            ) &&
                !expense.date
                    .isAfter(
                  currentRange.end,
                );

        return belongsToUser &&
            isInRange;
      },
    ).toList();
  }

  Map<String, double> _categoryTotals(
      List<Expense> expenses,
      ) {
    final Map<String, double> totals =
    {};

    for (final expense in expenses) {
      if (expense.isIncome) {
        continue;
      }

      totals[expense.category] =
          (totals[expense.category] ?? 0) +
              expense.amount;
    }

    return totals;
  }

  Map<String, double> _paymentTotals(
      List<Expense> expenses,
      ) {
    final Map<String, double> totals =
    {};

    for (final expense in expenses) {
      if (expense.isIncome) {
        continue;
      }

      totals[expense.paymentMethod] =
          (totals[expense.paymentMethod] ?? 0) +
              expense.amount;
    }

    return totals;
  }

  double _spent(
      List<Expense> expenses,
      ) {
    return expenses
        .where(
          (expense) =>
      !expense.isIncome,
    )
        .fold(
      0,
          (sum, expense) =>
      sum + expense.amount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<ExpenseProvider>();

    final userProvider =
    context.watch<UserProvider>();

    final selectedUser =
        userProvider.selectedUser;

    if (selectedUser == null) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding:
            const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.analytics_outlined,
                  size: 70,
                  color: AppColors.muted,
                ),
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  'No User Selected',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                const Text(
                  'Please select a user to view analytics.',
                  textAlign:
                  TextAlign.center,
                  style: TextStyle(
                    color:
                    AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final userExpenses =
    _filteredExpenses(
      provider.expenses,
      selectedUser.id,
    );

    final totals =
    _categoryTotals(
      userExpenses,
    );

    final spent =
    _spent(userExpenses);

    final payments =
    _paymentTotals(
      userExpenses,
    );

    return SafeArea(
      child: ListView(
        padding:
        const EdgeInsets.fromLTRB(
          24,
          10,
          24,
          24,
        ),
        children: [
          Row(
            children: [
              const Text(
                'Analytics',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
              const Spacer(),
              _periodMenu(),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.all(12),
            decoration:
            BoxDecoration(
              color:
              AppColors.greenDark,
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.person,
                  color:
                  AppColors.green,
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        selectedUser.name,
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                      Text(
                        selectedUser
                            .mobileNumber,
                        style:
                        const TextStyle(
                          color:
                          AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          AppCard(
            padding:
            const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              10,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Spent',
                  style: TextStyle(
                    color:
                    AppColors.muted,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  money(spent),
                  style:
                  const TextStyle(
                    fontSize: 28,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                SizedBox(
                  height: 150,
                  child: _barChart(
                    userExpenses,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          AppCard(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Category Breakdown',
                      style:
                      TextStyle(
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      money(spent),
                      style:
                      const TextStyle(
                        color:
                        AppColors.green,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 12,
                ),

                if (totals.isEmpty)
                  const Padding(
                    padding:
                    EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'No expense data',
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 165,
                    child: _pieChart(
                      totals,
                    ),
                  ),

                if (totals.isNotEmpty)
                  CategoryBreakdown(
                    totals: totals,
                    compact: true,
                  ),
              ],
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          AppCard(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Method',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                if (payments.isEmpty)
                  const Padding(
                    padding:
                    EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'No payment data',
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 160,
                    child:
                    _paymentChart(
                      payments,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          AppCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const WeeklyReportScreen(),
                ),
              );
            },
            child: const Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color:
                  AppColors.purple,
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Text(
                    'Generate Report',
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          AppCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const CustomReportScreen(),
                ),
              );
            },
            child: const Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  color:
                  AppColors.green,
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Text(
                    'View Custom Report',
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodMenu() {
    return PopupMenuButton<String>(
      initialValue: period,
      onSelected: (value) {
        setState(() {
          period = value;
        });
      },
      color: AppColors.card2,
      itemBuilder: (_) {
        return [
          'This Week',
          'This Month',
          'This Year',
        ].map(
              (value) {
            return PopupMenuItem(
              value: value,
              child: Text(value),
            );
          },
        ).toList();
      },
      child: Container(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 9,
        ),
        decoration:
        BoxDecoration(
          color:
          AppColors.greenDark,
          borderRadius:
          BorderRadius.circular(
            20,
          ),
        ),
        child: Text(
          period,
          style:
          const TextStyle(
            color:
            AppColors.green,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _barChart(
      List<Expense> expenses,
      ) {
    final now = DateTime.now();

    final bars =
    <BarChartGroupData>[];

    for (int i = 0; i < 7; i++) {
      final day =
      now.subtract(
        Duration(
          days: 6 - i,
        ),
      );

      final value =
      expenses
          .where(
            (expense) {
          return !expense.isIncome &&
              expense.date.year ==
                  day.year &&
              expense.date.month ==
                  day.month &&
              expense.date.day ==
                  day.day;
        },
      )
          .fold<double>(
        0,
            (sum, expense) =>
        sum + expense.amount,
      );

      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              width: 16,
              color: i == 6
                  ? AppColors.green
                  : AppColors.greenDark,
              borderRadius:
              BorderRadius.circular(
                5,
              ),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        minY: 0,
        gridData:
        const FlGridData(
          show: false,
        ),
        borderData:
        FlBorderData(
          show: false,
        ),
        titlesData:
        FlTitlesData(
          show: true,
          leftTitles:
          const AxisTitles(
            sideTitles:
            SideTitles(
              showTitles: false,
            ),
          ),
          topTitles:
          const AxisTitles(
            sideTitles:
            SideTitles(
              showTitles: false,
            ),
          ),
          rightTitles:
          const AxisTitles(
            sideTitles:
            SideTitles(
              showTitles: false,
            ),
          ),
          bottomTitles:
          AxisTitles(
            sideTitles:
            SideTitles(
              showTitles: true,
              getTitlesWidget:
                  (value, meta) {
                final labels = [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun',
                ];

                return Text(
                  labels[
                  value.toInt().clamp(
                    0,
                    6,
                  )],
                  style:
                  const TextStyle(
                    color:
                    AppColors.muted,
                    fontSize: 8,
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: bars,
      ),
    );
  }

  Widget _paymentChart(
      Map<String, double> payments,
      ) {
    final methods = [
      'UPI',
      'Cash',
      'Card',
    ];

    double max = 1;

    for (final value
    in payments.values) {
      if (value > max) {
        max = value;
      }
    }

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.end,
      mainAxisAlignment:
      MainAxisAlignment.spaceEvenly,
      children: methods.map(
            (method) {
          final value =
              payments[method] ?? 0;

          final height =
          max == 0
              ? 0.0
              : (90 *
              value /
              max);

          final color =
          method == 'UPI'
              ? AppColors.green
              : method == 'Cash'
              ? AppColors.orange
              : AppColors.blue;

          return Column(
            mainAxisAlignment:
            MainAxisAlignment.end,
            children: [
              Text(
                money(value),
                style:
                const TextStyle(
                  fontSize: 9,
                  color:
                  AppColors.muted,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              Container(
                width: 28,
                height:
                height.clamp(
                  0.0,
                  90.0,
                ),
                decoration:
                BoxDecoration(
                  color: color,
                  borderRadius:
                  BorderRadius.circular(
                    6,
                  ),
                ),
              ),

              const SizedBox(
                height: 7,
              ),

              Text(
                method,
                style:
                const TextStyle(
                  color:
                  AppColors.muted,
                  fontSize: 10,
                ),
              ),
            ],
          );
        },
      ).toList(),
    );
  }

  Widget _pieChart(
      Map<String, double> totals,
      ) {
    final entries =
    totals.entries.toList()
      ..sort(
            (a, b) =>
            b.value.compareTo(
              a.value,
            ),
      );

    return PieChart(
      PieChartData(
        centerSpaceRadius: 42,
        sectionsSpace: 2,
        sections: entries.map(
              (entry) {
            return PieChartSectionData(
              value: entry.value,
              color: categoryInfo(
                entry.key,
              ).color,
              radius: 22,
              showTitle: false,
            );
          },
        ).toList(),
        centerSpaceColor:
        Colors.black,
        borderData:
        FlBorderData(
          show: false,
        ),
      ),
    );
  }
}