import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_details_screen.dart';

class AllTransactionsScreen
    extends StatefulWidget {
  const AllTransactionsScreen({
    super.key,
  });

  @override
  State<AllTransactionsScreen>
  createState() =>
      _AllTransactionsScreenState();
}

class _AllTransactionsScreenState
    extends State<AllTransactionsScreen> {
  String query = '';

  String filter = 'All';

  @override
  Widget build(BuildContext context) {
    final expenseProvider =
    context.watch<ExpenseProvider>();

    final userProvider =
    context.watch<UserProvider>();

    final selectedUser =
        userProvider.selectedUser;

    if (selectedUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'All Transactions',
            style: TextStyle(
              fontWeight:
              FontWeight.w800,
            ),
          ),
        ),
        body: const Center(
          child: Padding(
            padding:
            EdgeInsets.all(24),
            child: Text(
              'Please select a user first',
              style: TextStyle(
                color:
                AppColors.muted,
                fontSize: 15,
              ),
            ),
          ),
        ),
      );
    }

    final source =
    expenseProvider.expenses
        .where(
          (expense) =>
      expense.userId ==
          selectedUser.id,
    )
        .toList()
      ..sort(
            (a, b) =>
            b.date.compareTo(
              a.date,
            ),
      );

    final data =
    source.where(
          (expense) {
        final matchesQuery =
            expense.title
                .toLowerCase()
                .contains(
              query.toLowerCase(),
            ) ||
                expense.category
                    .toLowerCase()
                    .contains(
                  query.toLowerCase(),
                ) ||
                expense.paymentMethod
                    .toLowerCase()
                    .contains(
                  query.toLowerCase(),
                );

        final matchesFilter =
            filter == 'All' ||
                (filter == 'Income' &&
                    expense.isIncome) ||
                (filter == 'Expense' &&
                    !expense.isIncome);

        return matchesQuery &&
            matchesFilter;
      },
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Transactions',
          style: TextStyle(
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding:
        const EdgeInsets.fromLTRB(
          20,
          4,
          20,
          24,
        ),
        children: [
          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.all(14),
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
                    .withOpacity(0.25),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor:
                  AppColors.green,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
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
                        'Selected User',
                        style: TextStyle(
                          color:
                          AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        selectedUser.name,
                        style:
                        const TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        selectedUser
                            .mobileNumber,
                        style:
                        const TextStyle(
                          color:
                          AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          TextField(
            onChanged: (value) {
              setState(() {
                query = value;
              });
            },
            decoration:
            const InputDecoration(
              prefixIcon:
              Icon(Icons.search),
              hintText:
              'Search transactions',
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Row(
            children: [
              'All',
              'Expense',
              'Income',
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
                    filter == value,
                    onSelected: (_) {
                      setState(() {
                        filter =
                            value;
                      });
                    },
                  ),
                );
              },
            ).toList(),
          ),

          const SizedBox(
            height: 14,
          ),

          if (data.isEmpty)
            const Padding(
              padding:
              EdgeInsets.all(40),
              child: Center(
                child: Text(
                  'No transactions found',
                  style: TextStyle(
                    color:
                    AppColors.muted,
                  ),
                ),
              ),
            ),

          ...data.map(
                (expense) {
              return Padding(
                padding:
                const EdgeInsets.only(
                  bottom: 8,
                ),
                child:
                TransactionTile(
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}