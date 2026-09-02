import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? editExpense;

  const AddExpenseScreen({
    super.key,
    this.editExpense,
  });

  @override
  State<AddExpenseScreen> createState() =>
      _AddExpenseScreenState();
}

class _AddExpenseScreenState
    extends State<AddExpenseScreen> {
  final amountController =
  TextEditingController();

  final titleController =
  TextEditingController();

  final noteController =
  TextEditingController();

  String category = 'Food';

  String payment = 'UPI';

  DateTime date =
  DateTime.now();

  bool isIncome = false;

  bool get isEditMode =>
      widget.editExpense != null;

  @override
  void initState() {
    super.initState();

    final expense =
        widget.editExpense;

    if (expense != null) {
      amountController.text =
          expense.amount.toString();

      titleController.text =
          expense.title;

      noteController.text =
          expense.note;

      category =
          expense.category;

      payment =
          expense.paymentMethod;

      date =
          expense.date;

      isIncome =
          expense.isIncome;
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    titleController.dispose();
    noteController.dispose();

    super.dispose();
  }



  Future<void> save() async {
    final amount =
    double.tryParse(
      amountController.text.trim(),
    );

    if (amount == null ||
        amount <= 0) {
      _message(
        'Enter a valid amount',
      );
      return;
    }

    if (titleController.text
        .trim()
        .isEmpty) {
      _message(
        'Please enter a title',
      );
      return;
    }



    final firebaseUser =
        FirebaseAuth
            .instance
            .currentUser;

    if (firebaseUser == null) {
      _message(
        'Please login first',
      );
      return;
    }

    final provider =
    context.read<
        ExpenseProvider>();

    final now =
    DateTime.now();

    final createdAt =
        widget.editExpense
            ?.createdAt ??
            now;

    final expense =
    Expense(
      id: widget.editExpense?.id ??
          DateTime.now()
              .microsecondsSinceEpoch
              .toString(),


      userId:
      firebaseUser.uid,

      title:
      titleController.text
          .trim(),

      amount: amount,

      category: category,

      paymentMethod: payment,

      date: date,

      note:
      noteController.text
          .trim(),

      isIncome: isIncome,

      createdAt: createdAt,

      updatedAt: now,
    );

    try {


      if (!isEditMode) {
        await provider.addExpense(
          expense,
        );
      }


      else {
        await provider.updateExpense(
          expense,
        );
      }

      if (!mounted) {
        return;
      }

      _message(
        isEditMode
            ? 'Expense updated successfully'
            : 'Expense saved successfully',
      );


      if (isEditMode) {
        Navigator.pop(context);
      } else {
        clearForm();
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      _message(
        'Error: $e',
      );
    }
  }



  void _message(
      String message,
      ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content:
        Text(message),
      ),
    );
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void clearForm() {
    amountController.clear();
    titleController.clear();
    noteController.clear();

    setState(() {
      category = 'Food';
      payment = 'UPI';
      date = DateTime.now();
      isIncome = false;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final firebaseUser =
        FirebaseAuth
            .instance
            .currentUser;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: ListView(
          padding:
          const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            24,
          ),
          children: [
            Text(
              isEditMode
                  ? 'Edit Expense'
                  : 'Add Expense',
              style:
              const TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // ==================================================
            // USER
            // ==================================================

            Container(
              width: double.infinity,
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
                  14,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                    AppColors.green
                        .withOpacity(
                      0.15,
                    ),
                    child:
                    Icon(
                      firebaseUser !=
                          null
                          ? Icons.person
                          : Icons.person_off,
                      color:
                      firebaseUser !=
                          null
                          ? AppColors
                          .green
                          : Colors
                          .redAccent,
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
                          firebaseUser
                              ?.displayName ??
                              firebaseUser
                                  ?.email ??
                              'User',
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),

                        if (firebaseUser
                            ?.email !=
                            null)
                          Text(
                            firebaseUser!
                                .email!,
                            style:
                            const TextStyle(
                              color:
                              AppColors
                                  .muted,
                              fontSize:
                              12,
                            ),
                          ),
                      ],
                    ),
                  ),

                  if (firebaseUser !=
                      null)
                    const Icon(
                      Icons.check_circle,
                      color:
                      AppColors.green,
                    ),
                ],
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // ==================================================
            // TYPE
            // ==================================================

            const Text(
              'Type',
              style:
              TextStyle(
                color:
                AppColors.muted,
                fontSize: 12,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label:
                  const Text(
                    'Expense',
                  ),
                  selected:
                  !isIncome,
                  onSelected: (_) {
                    setState(() {
                      isIncome =
                      false;
                    });
                  },
                ),
                ChoiceChip(
                  label:
                  const Text(
                    'Income',
                  ),
                  selected:
                  isIncome,
                  onSelected: (_) {
                    setState(() {
                      isIncome =
                      true;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(
              height: 18,
            ),

            // ==================================================
            // AMOUNT
            // ==================================================

            Container(
              width:
              double.infinity,
              height: 122,
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
                mainAxisAlignment:
                MainAxisAlignment
                    .center,
                children: [
                  const Text(
                    'Enter Amount',
                    style:
                    TextStyle(
                      color:
                      AppColors.muted,
                      fontSize: 11,
                    ),
                  ),

                  Padding(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 20,
                    ),
                    child:
                    TextField(
                      controller:
                      amountController,
                      textAlign:
                      TextAlign.center,
                      keyboardType:
                      const TextInputType
                          .numberWithOptions(
                        decimal: true,
                      ),
                      style:
                      const TextStyle(
                        fontSize: 32,
                        fontWeight:
                        FontWeight.w800,
                      ),
                      decoration:
                      const InputDecoration(
                        prefixText:
                        '₹ ',
                        border:
                        InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            // ==================================================
            // TITLE
            // ==================================================

            const Text(
              'Title',
              style:
              TextStyle(
                color:
                AppColors.muted,
                fontSize: 12,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            TextField(
              controller:
              titleController,
              decoration:
              const InputDecoration(
                hintText:
                'e.g. Lunch at Pizza Hut',
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            // ==================================================
            // CATEGORY
            // ==================================================

            const Text(
              'Category',
              style:
              TextStyle(
                color:
                AppColors.muted,
                fontSize: 12,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
              categories.map(
                    (item) {
                  final selected =
                      category ==
                          item.name;

                  return ChoiceChip(
                    selected:
                    selected,
                    label:
                    Text(
                      '${item.emoji} ${item.name}',
                    ),
                    onSelected:
                        (_) {
                      setState(() {
                        category =
                            item.name;
                      });
                    },
                    selectedColor:
                    AppColors
                        .greenDark,
                    backgroundColor:
                    AppColors.card,
                  );
                },
              ).toList(),
            ),

            const SizedBox(
              height: 18,
            ),

            // ==================================================
            // PAYMENT
            // ==================================================

            const Text(
              'Payment Method',
              style:
              TextStyle(
                color:
                AppColors.muted,
                fontSize: 12,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Wrap(
              spacing: 8,
              children: [
                paymentChoice(
                  'UPI',
                ),
                paymentChoice(
                  'Card',
                ),
                paymentChoice(
                  'Cash',
                ),
              ],
            ),

            const SizedBox(
              height: 18,
            ),

            // ==================================================
            // DATE
            // ==================================================

            const Text(
              'Date',
              style:
              TextStyle(
                color:
                AppColors.muted,
                fontSize: 12,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            InkWell(
              onTap:
                  () async {
                final picked =
                await showDatePicker(
                  context:
                  context,
                  firstDate:
                  DateTime(2020),
                  lastDate:
                  DateTime(2100),
                  initialDate:
                  date,
                  builder:
                      (
                      context,
                      child,
                      ) {
                    return Theme(
                      data: AppTheme
                          .darkTheme,
                      child:
                      child!,
                    );
                  },
                );

                if (picked !=
                    null) {
                  setState(() {
                    date =
                        DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          date.hour,
                          date.minute,
                        );
                  });
                }
              },
              child:
              Container(
                width:
                double.infinity,
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 14,
                  vertical: 17,
                ),
                decoration:
                BoxDecoration(
                  color:
                  AppColors.card,
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${date.day.toString().padLeft(2, '0')}/'
                            '${date.month.toString().padLeft(2, '0')}/'
                            '${date.year}',
                      ),
                    ),
                    const Icon(
                      Icons
                          .calendar_month,
                      color:
                      AppColors.green,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            // ==================================================
            // NOTE
            // ==================================================

            const Text(
              'Note (optional)',
              style:
              TextStyle(
                color:
                AppColors.muted,
                fontSize: 12,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            TextField(
              controller:
              noteController,
              maxLines: 3,
              decoration:
              const InputDecoration(
                hintText:
                'Add a note...',
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            // ==================================================
            // SAVE
            // ==================================================

            SizedBox(
              width:
              double.infinity,
              height: 48,
              child:
              ElevatedButton(
                onPressed:
                save,
                child: Text(
                  isEditMode
                      ? 'Update Expense'
                      : 'Save Expense',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PAYMENT CHOICE
  // ============================================================

  Widget paymentChoice(
      String value,
      ) {
    final selected =
        payment == value;

    return InkWell(
      onTap: () {
        setState(() {
          payment = value;
        });
      },
      child: Container(
        width: 95,
        padding:
        const EdgeInsets.symmetric(
          vertical: 14,
        ),
        decoration:
        BoxDecoration(
          color: selected
              ? AppColors.greenDark
              : Colors.transparent,
          borderRadius:
          BorderRadius.circular(
            12,
          ),
          border:
          Border.all(
            color: selected
                ? AppColors.green
                : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Icon(
              value == 'UPI'
                  ? Icons.qr_code_2
                  : value == 'Card'
                  ? Icons.credit_card
                  : Icons
                  .account_balance_wallet,
              color: selected
                  ? AppColors.green
                  : AppColors.muted,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              value,
              style:
              TextStyle(
                color: selected
                    ? AppColors.green
                    : AppColors.text,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}