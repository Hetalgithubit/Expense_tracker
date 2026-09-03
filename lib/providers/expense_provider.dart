import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/budget.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final List<Expense> _expenses = [];

  Budget _budget =
  const Budget();

  String? _selectedUserId;

  bool _isLoading = false;




  List<Expense> get expenses {
    final list =
    List<Expense>.from(_expenses);

    list.sort(
          (a, b) =>
          b.date.compareTo(a.date),
    );

    return List.unmodifiable(list);
  }

  Budget get budget => _budget;

  String? get selectedUserId =>
      _selectedUserId;

  String? get firebaseUserId =>
      _auth.currentUser?.uid;

  bool get isLoading =>
      _isLoading;





  DocumentReference<Map<String, dynamic>>?
  get _userDocument {
    final user =
        _auth.currentUser;

    if (user == null) {
      return null;
    }

    return _firestore
        .collection('users')
        .doc(user.uid);
  }




  CollectionReference<Map<String, dynamic>>?
  get _expenseCollection {
    final user =
        _auth.currentUser;

    if (user == null) {
      return null;
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('expenses');
  }


<<<<<<< HEAD
=======

>>>>>>> b20f2304806983d4e1f367df8d6e7e6e9ec06914

  DocumentReference<Map<String, dynamic>>?
  get _budgetDocument {
    final user =
        _auth.currentUser;

    if (user == null) {
      return null;
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('budget');
  }





  Future<void> init({
    String? userId,
  }) async {
    _isLoading = true;
    notifyListeners();

    _expenses.clear();
    _budget = const Budget();

    final firebaseUser =
        _auth.currentUser;

    if (firebaseUser == null) {
      _selectedUserId = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    final uid =
        firebaseUser.uid;

    _selectedUserId = uid;

    try {
      await loadBudgetFromFirestore();
      await loadExpensesFromFirestore();
    } catch (e) {
      debugPrint(
        'ExpenseProvider init error: $e',
      );
    }

    _isLoading = false;
    notifyListeners();
  }





  Future<void>
  loadExpensesFromFirestore() async {
    final firebaseUser =
        _auth.currentUser;

    if (firebaseUser == null) {
      _expenses.clear();
      _selectedUserId = null;
      notifyListeners();
      return;
    }

    final collection =
        _expenseCollection;

    if (collection == null) {
      return;
    }

    try {
      final snapshot =
      await collection.get();
      print('firebase expense data --> ${snapshot.toString()}');

      final List<Expense> loaded =
      [];

      // getting data from firestore
      for (final doc in snapshot.docs) {
        try {
          final expense =
          Expense.fromFirestore(doc);

          debugPrint(
            'LOADED FIRESTORE EXPENSE: '
                '${doc.id} | '
                '${expense.title} | '
                '${expense.amount} | '
                '${expense.category} | '
                '${expense.userId}',
          );

          loaded.add(expense);
        } catch (e) {
          debugPrint(
            'EXPENSE PARSE ERROR: '
                '${doc.id} | $e',
          );

          debugPrint(
            'RAW FIRESTORE DATA: '
                '${doc.data()}',
          );
        }
      }

      loaded.sort(
            (a, b) =>
            b.date.compareTo(a.date),
      );

      _expenses
        ..clear()
        ..addAll(loaded);

      _selectedUserId =
          firebaseUser.uid;



      debugPrint(
        'FIREBASE UID: '
            '${firebaseUser.uid}',
      );

      debugPrint(
        'FIRESTORE EXPENSE COUNT: '
            '${loaded.length}',
      );



      notifyListeners();
    } catch (e) {
      debugPrint(
        'Firestore expense load error: $e',
      );

      rethrow;
    }
  }


<<<<<<< HEAD

=======
>>>>>>> b20f2304806983d4e1f367df8d6e7e6e9ec06914


  Future<void>
  loadExpensesForUser(
      String userId,
      ) async {
    final firebaseUser =
        _auth.currentUser;

    if (firebaseUser == null) {
      clearUser();
      return;
    }

<<<<<<< HEAD

=======
>>>>>>> b20f2304806983d4e1f367df8d6e7e6e9ec06914

    final uid =
        firebaseUser.uid;

    _selectedUserId = uid;

    await loadExpensesFromFirestore();

    notifyListeners();
  }




  Future<void> setUser(
      String userId,
      ) async {
    await loadExpensesForUser(
      userId,
    );
  }




  void clearUser() {
    _selectedUserId = null;

    _expenses.clear();

    _budget = const Budget();

    _isLoading = false;

    notifyListeners();
  }


<<<<<<< HEAD

=======
>>>>>>> b20f2304806983d4e1f367df8d6e7e6e9ec06914


  Future<void> addExpense(
      Expense expense,
      ) async {
    final firebaseUser =
        _auth.currentUser;

    if (firebaseUser == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final uid =
        firebaseUser.uid;

    final collection =
        _expenseCollection;

    if (collection == null) {
      throw Exception(
        'Firestore expenses collection unavailable.',
      );
    }

    final now =
    DateTime.now();

    final newExpense =
    expense.copyWith(
      userId: uid,
      updatedAt: now,
    );





    await collection
        .doc(newExpense.id)
        .set(
      newExpense.toFirestoreMap(),
    );


<<<<<<< HEAD
=======

>>>>>>> b20f2304806983d4e1f367df8d6e7e6e9ec06914


    _selectedUserId = uid;

    _expenses.removeWhere(
          (item) =>
      item.id == newExpense.id,
    );

    _expenses.add(
      newExpense,
    );

    _expenses.sort(
          (a, b) =>
          b.date.compareTo(a.date),
    );

    debugPrint(
      'Expense saved successfully.',
    );

    debugPrint(
      'UID: $uid',
    );

    debugPrint(
      'Expense ID: ${newExpense.id}',
    );

    notifyListeners();
  }





  Future<void> updateExpense(
      Expense expense,
      ) async {
    final firebaseUser =
        _auth.currentUser;

    if (firebaseUser == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final uid =
        firebaseUser.uid;

    final collection =
        _expenseCollection;

    if (collection == null) {
      throw Exception(
        'Firestore expenses collection unavailable.',
      );
    }

    final index =
    _expenses.indexWhere(
          (item) =>
      item.id == expense.id,
    );

    final oldExpense =
    index >= 0
        ? _expenses[index]
        : null;

    final updatedExpense =
    expense.copyWith(
      userId: uid,
      createdAt:
      oldExpense?.createdAt ??
          expense.createdAt,
      updatedAt:
      DateTime.now(),
    );

    await collection
        .doc(updatedExpense.id)
        .set(
      updatedExpense.toFirestoreMap(),
      SetOptions(
        merge: true,
      ),
    );

    if (index >= 0) {
      _expenses[index] =
          updatedExpense;
    } else {
      _expenses.add(
        updatedExpense,
      );
    }

    _expenses.sort(
          (a, b) =>
          b.date.compareTo(a.date),
    );

    _selectedUserId = uid;

    notifyListeners();
  }


<<<<<<< HEAD

=======
>>>>>>> b20f2304806983d4e1f367df8d6e7e6e9ec06914


  Future<void> deleteExpense(
      String id,
      ) async {
    final firebaseUser =
        _auth.currentUser;

    if (firebaseUser == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final collection =
        _expenseCollection;

    if (collection == null) {
      throw Exception(
        'Firestore expenses collection unavailable.',
      );
    }

    await collection
        .doc(id)
        .delete();

    _expenses.removeWhere(
          (item) => item.id == id,
    );

    notifyListeners();
  }




  Expense? getExpenseById(
      String id,
      ) {
    try {
      return _expenses.firstWhere(
            (expense) =>
        expense.id == id,
      );
    } catch (_) {
      return null;
    }
  }




  Future<void>
  loadBudgetFromFirestore() async {
    final document =
        _budgetDocument;

    if (document == null) {
      return;
    }

    try {
      final snapshot =
      await document.get();

      if (!snapshot.exists) {
        _budget =
        const Budget();

        return;
      }

      final data =
      snapshot.data();

      if (data == null) {
        _budget =
        const Budget();

        return;
      }

      _budget =
          Budget.fromJson(data);

      debugPrint(
        'Budget loaded: '
            '${_budget.monthly}',
      );
    } catch (e) {
      debugPrint(
        'Budget load error: $e',
      );

      rethrow;
    }
  }




  Future<void>
  saveBudgetToFirestore(
      Budget budget,
      ) async {
    final firebaseUser =
        _auth.currentUser;

    if (firebaseUser == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final document =
        _budgetDocument;

    if (document == null) {
      throw Exception(
        'Budget document unavailable.',
      );
    }

    await document.set(
      {
        'monthly': budget.monthly,
        'categoryBudgets':
        budget.categoryBudgets,
        'updatedAt':
        FieldValue.serverTimestamp(),
      },
      SetOptions(
        merge: true,
      ),
    );

    _budget = Budget(
      monthly: budget.monthly,
      categoryBudgets:
      Map<String, double>.from(
        budget.categoryBudgets,
      ),
    );

    debugPrint(
      'Budget saved successfully.',
    );

    debugPrint(
      'UID: ${firebaseUser.uid}',
    );

    debugPrint(
      'Monthly budget: '
          '${_budget.monthly}',
    );

    notifyListeners();
  }





  Future<void> setMonthlyBudget(
      double value,
      ) async {
    if (value <= 0) {
      throw Exception(
        'Budget must be greater than zero.',
      );
    }

    final newBudget =
    Budget(
      monthly: value,
      categoryBudgets:
      Map<String, double>.from(
        _budget.categoryBudgets,
      ),
    );

    await saveBudgetToFirestore(
      newBudget,
    );
  }


<<<<<<< HEAD

=======
>>>>>>> b20f2304806983d4e1f367df8d6e7e6e9ec06914


  Future<void> setCategoryBudget(
      String category,
      double value,
      ) async {
    if (value <= 0) {
      throw Exception(
        'Category budget must be greater than zero.',
      );
    }

    final map =
    Map<String, double>.from(
      _budget.categoryBudgets,
    );

    map[category] = value;

    final newBudget =
    Budget(
      monthly: _budget.monthly,
      categoryBudgets: map,
    );

    await saveBudgetToFirestore(
      newBudget,
    );
  }





  List<Expense> inRange(
      DateTime from,
      DateTime to,
      ) {
    final end =
    DateTime(
      to.year,
      to.month,
      to.day,
      23,
      59,
      59,
      999,
    );

    return _expenses
        .where(
          (expense) =>
      !expense.date
          .isBefore(from) &&
          !expense.date
              .isAfter(end),
    )
        .toList();
  }




  List<Expense>
  get currentMonthExpenses {
    final now =
    DateTime.now();

    return inRange(
      DateTime(
        now.year,
        now.month,
        1,
      ),
      DateTime(
        now.year,
        now.month + 1,
        0,
      ),
    );
  }




  List<Expense>
  get currentMonthOnlyExpenses {
    return currentMonthExpenses
        .where(
          (expense) =>
      !expense.isIncome,
    )
        .toList();
  }



  double get monthlySpent {
    return currentMonthOnlyExpenses
        .fold<double>(
      0,
          (sum, expense) =>
      sum + expense.amount,
    );
  }


<<<<<<< HEAD

=======
>>>>>>> b20f2304806983d4e1f367df8d6e7e6e9ec06914

  double get monthlyIncome {
    return currentMonthExpenses
        .where(
          (expense) =>
      expense.isIncome,
    )
        .fold<double>(
      0,
          (sum, expense) =>
      sum + expense.amount,
    );
  }





  double get remainingBudget {
    return _budget.monthly -
        monthlySpent;
  }





  double get budgetPercent {
    if (_budget.monthly <= 0) {
      return 0;
    }

    return (monthlySpent /
        _budget.monthly)
        .clamp(
      0.0,
      1.0,
    )
        .toDouble();
  }





  Map<String, double>
  categoryTotals({
    DateTime? from,
    DateTime? to,
  }) {
    Iterable<Expense> source;

    if (from == null ||
        to == null) {
      source =
          currentMonthOnlyExpenses;
    } else {
      source = inRange(
        from,
        to,
      ).where(
            (expense) =>
        !expense.isIncome,
      );
    }

    final Map<String, double>
    result = {};

    for (final expense in source) {
      result[expense.category] =
          (result[expense.category] ??
              0) +
              expense.amount;
    }

    return result;
  }




  Map<String, double>
  paymentTotals({
    DateTime? from,
    DateTime? to,
  }) {
    Iterable<Expense> source;

    if (from == null ||
        to == null) {
      source =
          currentMonthOnlyExpenses;
    } else {
      source = inRange(
        from,
        to,
      ).where(
            (expense) =>
        !expense.isIncome,
      );
    }

    final Map<String, double>
    result = {};

    for (final expense in source) {
      result[
      expense.paymentMethod] =
          (result[
          expense.paymentMethod] ??
              0) +
              expense.amount;
    }

    return result;
  }





  double spentBetween(
      DateTime from,
      DateTime to,
      ) {
    return inRange(
      from,
      to,
    )
        .where(
          (expense) =>
      !expense.isIncome,
    )
        .fold<double>(
      0,
          (sum, expense) =>
      sum + expense.amount,
    );
  }


<<<<<<< HEAD
=======

>>>>>>> b20f2304806983d4e1f367df8d6e7e6e9ec06914

  double incomeBetween(
      DateTime from,
      DateTime to,
      ) {
    return inRange(
      from,
      to,
    )
        .where(
          (expense) =>
      expense.isIncome,
    )
        .fold<double>(
      0,
          (sum, expense) =>
      sum + expense.amount,
    );
  }
}