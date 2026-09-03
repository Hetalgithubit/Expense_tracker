import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({
    super.key,
  });

  @override
  State<BudgetScreen> createState() =>
      _BudgetScreenState();
}

class _BudgetScreenState
    extends State<BudgetScreen> {
  bool editing = false;

  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller =
        TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }



  Future<void> _editMonthlyBudget(
      ExpenseProvider provider,
      ) async {
    controller.text =
        provider.budget.monthly
            .toStringAsFixed(0);

    setState(() {
      editing = true;
    });
  }



  Future<void> _editCategoryBudget(
      ExpenseProvider provider,
      String category,
      ) async {
    final currentValue =
    provider
        .budget
        .categoryBudgets[
    category];

    final categoryController =
    TextEditingController(
      text: currentValue != null
          ? currentValue
          .toStringAsFixed(0)
          : '',
    );

    final value =
    await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            '$category Budget',
          ),
          content: TextField(
            controller:
            categoryController,
            autofocus: true,
            keyboardType:
            const TextInputType
                .numberWithOptions(
              decimal: true,
            ),
            decoration:
            const InputDecoration(
              prefixText: '₹ ',
              hintText:
              'Enter budget',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
              const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final parsed =
                double.tryParse(
                  categoryController
                      .text
                      .trim(),
                );

                if (parsed != null &&
                    parsed > 0) {
                  Navigator.pop(
                    dialogContext,
                    parsed,
                  );
                }
              },
              child:
              const Text('Save'),
            ),
          ],
        );
      },
    );

    categoryController.dispose();

    if (value == null) {
      return;
    }

    try {
      await provider
          .setCategoryBudget(
        category,
        value,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '$category budget saved successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unable to save budget: $e',
          ),
        ),
      );
    }
  }



  @override
  Widget build(
      BuildContext context,
      ) {
    final provider =
    context.watch<
        ExpenseProvider>();

    final totals =
    provider.categoryTotals();

    return SafeArea(
      child: ListView(
        padding:
        const EdgeInsets.fromLTRB(
          10,
          8,
          10,
          24,
        ),
        children: [
          const Text(
            'Budget',
            style: TextStyle(
              fontSize: 22,
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            '${_monthName(DateTime.now().month)} ${DateTime.now().year}',
            style:
            const TextStyle(
              color:
              AppColors.muted,
            ),
          ),

          const SizedBox(height: 18),


          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      const Text(
                        'Monthly Budget',
                        style:
                        TextStyle(
                          color:
                          AppColors
                              .muted,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        money(
                          provider
                              .budget
                              .monthly,
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
                        height: 8,
                      ),

                      Text(
                        'Spent: ${money(provider.monthlySpent)}',
                        style:
                        const TextStyle(
                          color:
                          AppColors
                              .red,
                          fontSize: 11,
                        ),
                      ),

                      Text(
                        'Remaining: ${money(provider.remainingBudget)}',
                        style:
                        const TextStyle(
                          color:
                          AppColors
                              .green,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: 82,
                  height: 82,
                  child: Stack(
                    alignment:
                    Alignment.center,
                    children: [
                      const CircularProgressIndicator(
                        value: 1,
                        color:
                        AppColors
                            .greenDark,
                        strokeWidth: 8,
                      ),

                      CircularProgressIndicator(
                        value: provider
                            .budgetPercent
                            .clamp(
                          0.0,
                          1.0,
                        )
                            .toDouble(),
                        color:
                        AppColors
                            .green,
                        strokeWidth: 8,
                      ),

                      Text(
                        '${(provider.budgetPercent * 100).round()}%',
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight
                              .w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 28,
          ),

          const Text(
            'Category Budgets',
            style: TextStyle(
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 12,
          ),


          ...categories.take(6).map(
                (category) {
              final spent =
              (totals[
              category
                  .name] ??
                  0)
                  .toDouble();

              final savedLimit =
              provider
                  .budget
                  .categoryBudgets[
              category.name];

              final limit =
              (savedLimit ??
                  provider
                      .budget
                      .monthly /
                      6)
                  .toDouble();

              double percent;

              if (limit <= 0) {
                percent = 0.0;
              } else {
                percent =
                    spent / limit;
              }

              percent = percent
                  .clamp(
                0.0,
                1.0,
              )
                  .toDouble();

              return Padding(
                padding:
                const EdgeInsets
                    .only(
                  bottom: 10,
                ),
                child: AppCard(
                  padding:
                  const EdgeInsets
                      .all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CategoryIcon(
                            category.name,
                            size: 36,
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Expanded(
                            child:
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Text(
                                  category
                                      .name,
                                  style:
                                  const TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .w700,
                                  ),
                                ),

                                const SizedBox(
                                  height: 2,
                                ),

                                Text(
                                  'Spent: ${money(spent)}',
                                  style:
                                  const TextStyle(
                                    color:
                                    AppColors
                                        .muted,
                                    fontSize:
                                    11,
                                  ),
                                ),

                                const SizedBox(
                                  height: 2,
                                ),

                                Text(
                                  'Budget: ${money(limit)}',
                                  style:
                                  const TextStyle(
                                    color:
                                    AppColors
                                        .muted,
                                    fontSize:
                                    11,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Text(
                            '${(percent * 100).round()}%',
                            style:
                            const TextStyle(
                              color:
                              AppColors
                                  .green,
                              fontSize:
                              12,
                              fontWeight:
                              FontWeight
                                  .w700,
                            ),
                          ),



                          const SizedBox(
                            width: 4,
                          ),



                        ],
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      ProgressLine(
                        value:
                        percent,
                        color:
                        AppColors
                            .green,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(
            height: 4,
          ),



          if (editing) ...[
            const Text(
              "Set This Month's Budget",
              style: TextStyle(
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            TextField(
              controller:
              controller,
              keyboardType:
              const TextInputType
                  .numberWithOptions(
                decimal: true,
              ),
              decoration:
              const InputDecoration(
                prefixText: '₹ ',
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            SizedBox(
              height: 46,
              child:
              ElevatedButton(
                onPressed:
                    () async {
                  final value =
                  double.tryParse(
                    controller
                        .text
                        .trim(),
                  );

                  if (value ==
                      null ||
                      value <= 0) {
                    ScaffoldMessenger
                        .of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please enter a valid budget.',
                        ),
                      ),
                    );
                    return;
                  }

                  try {
                    await provider
                        .setMonthlyBudget(
                      value,
                    );

                    if (!mounted) {
                      return;
                    }

                    setState(() {
                      editing =
                      false;
                    });

                    ScaffoldMessenger
                        .of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Monthly budget saved successfully',
                        ),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) {
                      return;
                    }

                    ScaffoldMessenger
                        .of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Unable to save budget: $e',
                        ),
                      ),
                    );
                  }
                },
                child:
                const Text(
                  'Save Budget',
                ),
              ),
            ),
          ] else
            SizedBox(
              height: 48,
              child:
              ElevatedButton.icon(
                onPressed: () {
                  _editMonthlyBudget(
                    provider,
                  );
                },
                icon: const Icon(
                  Icons.edit,
                ),
                label:
                const Text(
                  "Update This Month's Budget",
                ),
              ),
            ),
        ],
      ),
    );
  }


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