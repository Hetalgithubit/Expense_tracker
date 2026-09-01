import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

class TransactionTile extends StatelessWidget {
  final Expense expense;

  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.expense,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final amountColor =
    expense.isIncome
        ? AppColors.green
        : AppColors.red;

    return AppCard(
      onTap: onTap,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      child: Row(
        children: [
          CategoryIcon(
            expense.category,
            size: 42,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  dateTimeLabel(
                    expense.date,
                  ),
                  style:
                  const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '${expense.isIncome ? '+' : '-'}'
                '${money(expense.amount)}',
            style: TextStyle(
              color: amountColor,
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}