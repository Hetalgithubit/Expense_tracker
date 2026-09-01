import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'add_expense_screen.dart';

class TransactionDetailsScreen
    extends StatelessWidget {
  final String expenseId;

  const TransactionDetailsScreen({
    super.key,
    required this.expenseId,
  });

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<ExpenseProvider>();

    final matchingExpenses =
    provider.expenses.where(
          (item) => item.id == expenseId,
    );

    if (matchingExpenses.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text(
            'Transaction',
          ),
        ),
        body: const Center(
          child: Text(
            'Transaction not found',
          ),
        ),
      );
    }

    final expense =
        matchingExpenses.first;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          4,
          10,
          4,
          24,
        ),
        children: [
          Center(
            child: Column(
              children: [
                CategoryIcon(
                  expense.category,
                  size: 96,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  expense.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                Text(
                  expense.category
                      .toUpperCase(),
                  style: const TextStyle(
                    color:
                    AppColors.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 22,
          ),
          AppCard(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transaction Amount',
                  style: TextStyle(
                    color:
                    AppColors.muted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  '${expense.isIncome ? '+' : ''}'
                      '${money(expense.amount)}',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight:
                    FontWeight.w800,
                    color: expense.isIncome
                        ? AppColors.green
                        : AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          AppCard(
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color:
                  AppColors.muted,
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
                        'Date & Time',
                        style: TextStyle(
                          color:
                          AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        dateTimeLabel(
                          expense.date,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            children: [
              Expanded(
                child: AppCard(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      const Icon(
                        Icons.credit_card,
                        color:
                        AppColors.muted,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text(
                        'Payment',
                        style: TextStyle(
                          color:
                          AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        expense.paymentMethod,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: AppCard(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      const Icon(
                        Icons.category_outlined,
                        color:
                        AppColors.muted,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text(
                        'Category',
                        style: TextStyle(
                          color:
                          AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        expense.category,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (expense.note.isNotEmpty) ...[
            const SizedBox(
              height: 12,
            ),
            AppCard(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Note',
                    style: TextStyle(
                      color:
                      AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                    expense.note,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddExpenseScreen(
                          editExpense:
                          expense,
                        ),
                  ),
                );

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(
                Icons.edit,
              ),
              label: const Text(
                'Edit Expense',
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              style:
              OutlinedButton.styleFrom(
                foregroundColor:
                AppColors.red,
                side: const BorderSide(
                  color:
                  AppColors.red,
                ),
              ),
              onPressed: () async {
                final ok =
                await showDialog<bool>(
                  context: context,
                  builder: (_) =>
                      AlertDialog(
                        backgroundColor:
                        AppColors.card,
                        title: const Text(
                          'Delete Expense?',
                        ),
                        content:
                        const Text(
                          'This transaction will be permanently removed.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(
                                context,
                                false,
                              );
                            },
                            child:
                            const Text(
                              'Cancel',
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(
                                context,
                                true,
                              );
                            },
                            child:
                            const Text(
                              'Delete',
                            ),
                          ),
                        ],
                      ),
                );

                if (ok == true) {
                  await context
                      .read<
                      ExpenseProvider>()
                      .deleteExpense(
                    expense.id,
                  );

                  if (context.mounted) {
                    Navigator.pop(
                      context,
                    );
                  }
                }
              },
              icon: const Icon(
                Icons.delete_outline,
              ),
              label: const Text(
                'Delete Expense',
              ),
            ),
          ),
        ],
      ),
    );
  }
}