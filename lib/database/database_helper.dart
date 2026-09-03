import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/budget.dart';
import '../models/expense.dart';
import '../models/user.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance =
  DatabaseHelper._privateConstructor();

  static Database? _database;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;





  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath =
    await getDatabasesPath();

    final path = join(
      databasePath,
      'expense_tracker.db',
    );

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(
      Database db,
      ) async {
    await db.execute(
      'PRAGMA foreign_keys = ON',
    );
  }





  Future<void> _onCreate(
      Database db,
      int version,
      ) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        mobile_number TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');


    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        is_income INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        id INTEGER PRIMARY KEY,
        user_id TEXT NOT NULL,
        budget_data TEXT,
        UNIQUE(user_id)
      )
    ''');
  }





  Future<void> _onUpgrade(
      Database db,
      int oldVersion,
      int newVersion,
      ) async{
    // VERSION 2


    if (oldVersion < 2) {
      final usersTableExists =
      await _tableExists(
        db,
        'users',
      );

      if (!usersTableExists) {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            mobile_number TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      }

      final expenseColumns =
      await db.rawQuery(
        'PRAGMA table_info(expenses)',
      );

      final hasUserId =
      expenseColumns.any(
            (column) =>
        column['name'] ==
            'user_id',
      );

      if (!hasUserId) {
        await db.execute('''
          ALTER TABLE expenses
          ADD COLUMN user_id TEXT
        ''');
      }
    }




    if (oldVersion < 3) {
      final settingsExists =
      await _tableExists(
        db,
        'app_settings',
      );

      if (settingsExists) {
        await db.execute('''
          CREATE TABLE app_settings_new (
            id INTEGER PRIMARY KEY,
            user_id TEXT NOT NULL,
            budget_data TEXT,
            UNIQUE(user_id)
          )
        ''');

        await db.execute('''
          INSERT OR IGNORE INTO app_settings_new
          (id, user_id, budget_data)
          SELECT id, user_id, budget_data
          FROM app_settings
        ''');

        await db.execute('''
          DROP TABLE app_settings
        ''');

        await db.execute('''
          ALTER TABLE app_settings_new
          RENAME TO app_settings
        ''');
      } else {
        await db.execute('''
          CREATE TABLE app_settings (
            id INTEGER PRIMARY KEY,
            user_id TEXT NOT NULL,
            budget_data TEXT,
            UNIQUE(user_id)
          )
        ''');
      }
    }





    if (oldVersion < 4) {
      await _rebuildExpensesTable(
        db,
      );
    }
  }





  Future<void> _rebuildExpensesTable(
      Database db,
      ) async {
    final exists =
    await _tableExists(
      db,
      'expenses',
    );

    if (!exists) {
      await db.execute('''
        CREATE TABLE expenses (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          category TEXT NOT NULL,
          payment_method TEXT NOT NULL,
          date TEXT NOT NULL,
          note TEXT,
          is_income INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      return;
    }

    await db.execute('''
      CREATE TABLE expenses_new (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        is_income INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      INSERT OR IGNORE INTO expenses_new
      (
        id,
        user_id,
        title,
        amount,
        category,
        payment_method,
        date,
        note,
        is_income,
        created_at,
        updated_at
      )
      SELECT
        id,
        COALESCE(user_id, ''),
        title,
        amount,
        category,
        payment_method,
        date,
        note,
        is_income,
        created_at,
        updated_at
      FROM expenses
    ''');

    await db.execute('''
      DROP TABLE expenses
    ''');

    await db.execute('''
      ALTER TABLE expenses_new
      RENAME TO expenses
    ''');
  }


  // CHECK TABLE


  Future<bool> _tableExists(
      Database db,
      String tableName,
      ) async {
    final result =
    await db.rawQuery(
      '''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
      AND name = ?
      ''',
      [tableName],
    );

    return result.isNotEmpty;
  }


  // USERS


  Future<int> insertUser(
      User user,
      ) async {
    final db =
    await database;

    return await db.insert(
      'users',
      user.toDatabaseMap(),
      conflictAlgorithm:
      ConflictAlgorithm.replace,
    );
  }

  Future<List<User>>
  getUsers() async {
    final db =
    await database;

    final maps =
    await db.query(
      'users',
      orderBy:
      'name ASC',
    );

    return maps
        .map(
          (map) =>
          User.fromDatabaseMap(
            map,
          ),
    )
        .toList();
  }

  Future<User?>
  getUserById(
      String id,
      ) async {
    final db =
    await database;

    final maps =
    await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return User.fromDatabaseMap(
      maps.first,
    );
  }

  Future<int> updateUser(
      User user,
      ) async {
    final db =
    await database;

    return await db.update(
      'users',
      user.toDatabaseMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(
      String id,
      ) async {
    final db =
    await database;

    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }



  Future<int> insertExpense(
      Expense expense,
      ) async {
    final db =
    await database;



    return await db.insert(
      'expenses',
      expense.toDatabaseMap(),
      conflictAlgorithm:
      ConflictAlgorithm.replace,
    );
  }

  Future<int> updateExpense(
      Expense expense,
      ) async {
    final db =
    await database;

    return await db.update(
      'expenses',
      expense.toDatabaseMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(
      String id,
      ) async {
    final db =
    await database;

    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Expense>>
  getExpenses() async {
    final db =
    await database;

    final maps =
    await db.query(
      'expenses',
      orderBy:
      'date DESC',
    );

    return maps
        .map(
          (map) =>
          Expense.fromDatabaseMap(
            map,
          ),
    )
        .toList();
  }

  Future<List<Expense>>
  getExpensesByUser(
      String userId,
      ) async {
    final db =
    await database;

    final maps =
    await db.query(
      'expenses',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy:
      'date DESC',
    );

    return maps
        .map(
          (map) =>
          Expense.fromDatabaseMap(
            map,
          ),
    )
        .toList();
  }

  Future<Expense?>
  getExpenseById(
      String id,
      ) async {
    final db =
    await database;

    final maps =
    await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Expense.fromDatabaseMap(
      maps.first,
    );
  }

  Future<int>
  getExpenseCount() async {
    final db =
    await database;

    final result =
    await db.rawQuery(
      'SELECT COUNT(*) as count FROM expenses',
    );

    return Sqflite
        .firstIntValue(
      result,
    ) ??
        0;
  }

  Future<int>
  getExpenseCountByUser(
      String userId,
      ) async {
    final db =
    await database;

    final result =
    await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM expenses
      WHERE user_id = ?
      ''',
      [userId],
    );

    return Sqflite
        .firstIntValue(
      result,
    ) ??
        0;
  }



  Future<void> saveBudget(
      String userId,
      Budget budget,
      ) async {
    if (userId.trim().isEmpty) {
      throw Exception(
        'Firebase User ID is required.',
      );
    }

    try {
      final budgetRef =
      _firestore
          .collection(
        'users',
      )
          .doc(userId)
          .collection(
        'settings',
      )
          .doc('budget');

      // Firestore
      await budgetRef.set(
        {
          'monthly':
          budget.monthly,
          'categoryBudgets':
          budget.categoryBudgets,
          'updatedAt':
          FieldValue
              .serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      // Local SQLite backup
      try {
        final db =
        await database;

        await db.insert(
          'app_settings',
          {
            'user_id':
            userId,
            'budget_data':
            jsonEncode(
              budget.toJson(),
            ),
          },
          conflictAlgorithm:
          ConflictAlgorithm
              .replace,
        );
      } catch (e) {

        print(
          'Local budget save failed: $e',
        );
      }
    } on FirebaseException catch (e) {
      throw Exception(
        'Unable to save budget: '
            '[${e.code}] ${e.message}',
      );
    } catch (e) {
      throw Exception(
        'Unable to save budget: $e',
      );
    }
  }





  Future<Budget?> getBudget(
      String userId,
      ) async {
    if (userId.trim().isEmpty) {
      return null;
    }

    try {
      final budgetRef =
      _firestore
          .collection(
        'users',
      )
          .doc(userId)
          .collection(
        'settings',
      )
          .doc('budget');

      final snapshot =
      await budgetRef.get();

      if (!snapshot.exists) {
        return null;
      }

      final data =
      snapshot.data();

      if (data == null) {
        return null;
      }

      return Budget.fromJson(
        Map<String, dynamic>.from(
          data,
        ),
      );
    } on FirebaseException catch (e) {
      throw Exception(
        'Unable to load budget: '
            '[${e.code}] ${e.message}',
      );
    } catch (e) {
      throw Exception(
        'Unable to load budget: $e',
      );
    }
  }





  Future<Budget?>
  getLocalBudget(
      String userId,
      ) async {
    final db =
    await database;

    final result =
    await db.query(
      'app_settings',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    final budgetData =
    result.first[
    'budget_data'];

    if (budgetData == null) {
      return null;
    }

    try {
      final json =
      jsonDecode(
        budgetData as String,
      );

      return Budget.fromJson(
        Map<String, dynamic>.from(
          json,
        ),
      );
    } catch (_) {
      return null;
    }
  }





  Future<void>
  closeDatabase() async {
    if (_database == null) {
      return;
    }

    await _database!.close();

    _database = null;
  }
}