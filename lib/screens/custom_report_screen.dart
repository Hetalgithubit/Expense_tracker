import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/category_breakdown.dart';
import '../widgets/common_widgets.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_details_screen.dart';

class CustomReportScreen
    extends StatefulWidget {
  const CustomReportScreen({
    super.key,
  });

  @override
  State<CustomReportScreen>
  createState() =>
      _CustomReportScreenState();
}




class _CustomReportScreenState
    extends State<CustomReportScreen> {
  String selected =
      'This Month';

  DateTime? customFrom;

  DateTime? customTo;

  DateTimeRange _range() {
    final now = DateTime.now();

    if (selected == 'This Week') {
      return DateTimeRange(
        start: now.subtract(
          Duration(
            days: now.weekday - 1,
          ),
        ),
        end: now,
      );
    }


    if (selected == 'This Year') {
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
        ),
      );
    }





    if (selected == 'Custom' &&
        customFrom != null &&
        customTo != null) {
      return DateTimeRange(
        start: customFrom!,
        end: customTo!,
      );
    }



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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<ExpenseProvider>();

    final range = _range();

    final list =
    provider
        .inRange(
      range.start,
      range.end,
    )
        .where(
          (expense) =>
      !expense.isIncome,
    )
        .toList()
      ..sort(
            (a, b) =>
            b.date.compareTo(a.date),
      );

    final total = list.fold(
      0.0,
          (sum, expense) =>
      sum + expense.amount,
    );

    final categories =
    provider.categoryTotals(
      from: range.start,
      to: range.end,
    );

    final payments =
    provider.paymentTotals(
      from: range.start,
      to: range.end,
    );

    final average =
    list.isEmpty
        ? 0
        : total / list.length;

    final top =
    categories.entries.toList()
      ..sort(
            (a, b) =>
            b.value.compareTo(a.value),
      );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Custom Report',
          style: TextStyle(
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),

      body: ListView(
        padding:
        const EdgeInsets.fromLTRB(
          16,
          4,
          16,
          24,
        ),
        children: [
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection:
              Axis.horizontal,
              children: [
                'This Week',
                'This Month',
                'This Year',
                'Custom',
              ].map(
                    (value) {
                  return Padding(
                    padding:
                    const EdgeInsets.only(
                      right: 8,
                    ),
                    child: ChoiceChip(
                      label:
                      Text(value),
                      selected:
                      selected ==
                          value,
                      onSelected:
                          (_) async {
                        setState(() {
                          selected =
                              value;
                        });

                        if (value ==
                            'Custom') {
                          await _pickCustom();
                        }
                      },
                    ),
                  );
                },
              ).toList(),
            ),
          ),

          if (selected ==
              'Custom' &&
              customFrom != null &&
              customTo != null)
            Padding(
              padding:
              const EdgeInsets.only(
                bottom: 10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _dateBox(
                      'From',
                      customFrom!,
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child: _dateBox(
                      'To',
                      customTo!,
                    ),
                  ),
                ],
              ),
            ),

          AppCard(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  '${shortDate(range.start)} - '
                      '${shortDate(range.end)}',
                  style:
                  const TextStyle(
                    color:
                    AppColors.muted,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(
                  height: 18,
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
                  height: 24,
                ),

                _row(
                  'Total Budget',
                  money(
                    provider.budget.monthly,
                  ),
                ),

                _row(
                  'Remaining',
                  money(
                    provider.budget.monthly -
                        total,
                  ),
                ),

                _row(
                  'Transactions',
                  '${list.length}',
                ),

                _row(
                  'Average Expense',
                  money(
                    average.toDouble(),
                  ),
                ),

                _row(
                  'Top Category',
                  top.isEmpty
                      ? '—'
                      : top.first.key,
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

          const SizedBox(
            height: 16,
          ),

          AppCard(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Method',
                  style:
                  TextStyle(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                ...[
                  'UPI',
                  'Cash',
                  'Card',
                ].map(
                      (method) {
                    final value =
                        payments[
                        method] ??
                            0;

                    final color =
                    method == 'UPI'
                        ? AppColors
                        .green
                        : method ==
                        'Cash'
                        ? AppColors
                        .orange
                        : AppColors
                        .blue;

                    return Padding(
                      padding:
                      const EdgeInsets
                          .only(
                        bottom: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Text(
                                  method,
                                  style:
                                  const TextStyle(
                                    color:
                                    AppColors.muted,
                                    fontSize:
                                    12,
                                  ),
                                ),

                                const SizedBox(
                                  height: 5,
                                ),

                                ProgressLine(
                                  value:
                                  total ==
                                      0
                                      ? 0
                                      : value /
                                      total,
                                  color:
                                  color,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Text(
                            money(value),
                            style:
                            TextStyle(
                              color:
                              color,
                              fontWeight:
                              FontWeight
                                  .w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
                Row(
                  children: [
                    const Text(
                      'Transactions',
                      style:
                      TextStyle(
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      '${list.length}',
                      style:
                      const TextStyle(
                        color:
                        AppColors.muted,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 10,
                ),

                ...list.take(5).map(
                      (expense) {
                    return Padding(
                      padding:
                      const EdgeInsets
                          .only(
                        bottom: 8,
                      ),
                      child:
                      TransactionTile(
                        expense:
                        expense,
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
                      ),
                    );
                  },
                ),

                if (list.length > 5)
                  const Center(
                    child: Text(
                      'View All',
                      style:
                      TextStyle(
                        color:
                        AppColors.green,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
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

  Widget _dateBox(
      String label,
      DateTime date,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(10),
      decoration:
      BoxDecoration(
        border: Border.all(
          color:
          AppColors.green,
        ),
        borderRadius:
        BorderRadius.circular(
          14,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
            const TextStyle(
              color:
              AppColors.muted,
              fontSize: 10,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            shortDate(date),
            style:
            const TextStyle(
              color:
              AppColors.green,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCustom() async {
    final now = DateTime.now();

    final first =
    await showDatePicker(
      context: context,
      firstDate:
      DateTime(2020),
      lastDate:
      DateTime(2100),
      initialDate:
      customFrom ??
          DateTime(
            now.year,
            now.month,
            1,
          ),
    );

    if (first == null ||
        !mounted) {
      return;
    }

    final second =
    await showDatePicker(
      context: context,
      firstDate: first,
      lastDate:
      DateTime(2100),
      initialDate:
      customTo ?? now,
    );

    if (second == null) {
      return;
    }

    setState(() {
      customFrom = first;
      customTo = second;
    });
  }
}