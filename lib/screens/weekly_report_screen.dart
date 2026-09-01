import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/category_breakdown.dart';
import '../widgets/common_widgets.dart';

class WeeklyReportScreen
    extends StatelessWidget {
  const WeeklyReportScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<ExpenseProvider>();

    final now = DateTime.now();

    final from = now.subtract(
      Duration(
        days: now.weekday - 1,
      ),
    );

    final to = now;

    final data =
    provider
        .inRange(from, to)
        .where(
          (expense) =>
      !expense.isIncome,
    )
        .toList();

    final total = data.fold(
      0.0,
          (sum, expense) =>
      sum + expense.amount,
    );

    final categories =
    provider.categoryTotals(
      from: from,
      to: to,
    );

    final top =
    categories.entries.toList()
      ..sort(
            (a, b) =>
            b.value.compareTo(a.value),
      );

    final average =
    data.isEmpty
        ? 0
        : total / data.length;

    final highestDay =
    data.isEmpty
        ? '—'
        : _highestDay(data);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weekly Report',
          style: TextStyle(
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),

      body: ListView(
        padding:
        const EdgeInsets.all(18),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly Money Report',
                  style:
                  TextStyle(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  '${shortDate(from)} - ${shortDate(to)}',
                  style:
                  const TextStyle(
                    color:
                    AppColors.muted,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),

                const Text(
                  'Total Spent',
                  style:
                  TextStyle(
                    color:
                    AppColors.muted,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  money(total),
                  style:
                  const TextStyle(
                    fontSize: 28,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),

                _row(
                  'Transactions',
                  '${data.length}',
                ),

                _row(
                  'Highest Category',
                  top.isEmpty
                      ? '—'
                      : '${top.first.key} '
                      '${(top.first.value / (total == 0 ? 1 : total) * 100).round()}%',
                ),

                _row(
                  'Highest Day',
                  highestDay,
                ),

                _row(
                  'Average Expense',
                  money(
                    average.toDouble(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          AppCard(
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                  const EdgeInsets.all(
                    10,
                  ),
                  decoration:
                  BoxDecoration(
                    color: AppColors
                        .purple
                        .withOpacity(.15),
                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color:
                    AppColors.purple,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Tip',
                        style:
                        TextStyle(
                          color:
                          AppColors.purple,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),

                      SizedBox(
                        height: 6,
                      ),

                      Text(
                        'You spent more on your top category this week. Try cutting back next week to improve your savings.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          AppCard(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Category Breakdown',
                  style:
                  TextStyle(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                CategoryBreakdown(
                  totals: categories,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
      String title,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        children: [
          Text(
            title,
            style:
            const TextStyle(
              color:
              AppColors.muted,
            ),
          ),

          const Spacer(),

          Text(
            value,
            style:
            const TextStyle(
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _highestDay(
      List data,
      ) {
    final map =
    <int, double>{};

    for (final expense in data) {
      map[expense.date.weekday] =
          (map[expense.date.weekday] ??
              0) +
              expense.amount;
    }

    final day =
        map.entries.reduce(
              (a, b) =>
          a.value >= b.value
              ? a
              : b,
        ).key;

    return const [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ][day - 1];
  }
}