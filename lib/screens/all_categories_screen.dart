import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/category_breakdown.dart';
import '../widgets/common_widgets.dart';

class AllCategoriesScreen
    extends StatelessWidget {
  const AllCategoriesScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final totals =
    context
        .watch<ExpenseProvider>()
        .categoryTotals();

    final total = totals.values.fold(
      0.0,
          (a, b) => a + b,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Categories',
          style: TextStyle(
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),

      body: ListView(
        padding:
        const EdgeInsets.all(16),
        children: [
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
                      money(total),
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
                  height: 14,
                ),

                CategoryBreakdown(
                  totals: totals,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}