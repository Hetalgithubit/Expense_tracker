import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart'
    show User;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/user_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options:
    DefaultFirebaseOptions
        .currentPlatform,
  );

  final authProvider =
  AuthProvider();

  final userProvider =
  UserProvider();

  final expenseProvider =
  ExpenseProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
        ),
        ChangeNotifierProvider<UserProvider>.value(
          value: userProvider,
        ),
        ChangeNotifierProvider<ExpenseProvider>.value(
          value: expenseProvider,
        ),
      ],
      child: ExpenseTrackerApp(
        authProvider:
        authProvider,
        userProvider:
        userProvider,
        expenseProvider:
        expenseProvider,
      ),
    ),
  );
}

class ExpenseTrackerApp
    extends StatefulWidget {
  final AuthProvider authProvider;
  final UserProvider userProvider;
  final ExpenseProvider expenseProvider;

  const ExpenseTrackerApp({
    super.key,
    required this.authProvider,
    required this.userProvider,
    required this.expenseProvider,
  });

  @override
  State<ExpenseTrackerApp> createState() =>
      _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState
    extends State<ExpenseTrackerApp> {
  late Future<void>
  initialization;

  StreamSubscription<User?>?
  _authSubscription;

  @override
  void initState() {
    super.initState();

    initialization =
        _initializeApp();

    _authSubscription =
        widget
            .authProvider
            .authStateChanges
            .listen(
          _handleAuthStateChanged,
        );
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void>
  _initializeApp() async {
    await widget
        .authProvider
        .init();

    await widget
        .userProvider
        .init();

    final uid =
        widget.authProvider.userId;

    if (uid != null &&
        uid.isNotEmpty) {
      await widget
          .expenseProvider
          .init(
        userId: uid,
      );
    } else {
      widget
          .expenseProvider
          .clearUser();
    }
  }

  // ============================================================
  // LOGIN / LOGOUT
  // ============================================================

  Future<void>
  _handleAuthStateChanged(
      User? firebaseUser,
      ) async {
    if (!mounted) {
      return;
    }

    if (firebaseUser != null) {
      final uid =
          firebaseUser.uid;

      debugPrint(
        'AUTH LOGIN UID: $uid',
      );

      await widget
          .userProvider
          .init();

      await widget
          .expenseProvider
          .init(
        userId: uid,
      );
    } else {
      debugPrint(
        'AUTH LOGOUT',
      );

      widget
          .userProvider
          .clearUser();

      widget
          .expenseProvider
          .clearUser();
    }
  }

  // ============================================================
  // RETRY
  // ============================================================

  void retryInitialization() {
    setState(() {
      initialization =
          _initializeApp();
    });
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _authSubscription
        ?.cancel();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return MaterialApp(
      debugShowCheckedModeBanner:
      false,
      title:
      'Expense Tracker',
      theme:
      AppTheme.darkTheme,
      home:
      FutureBuilder<void>(
        future:
        initialization,
        builder:
            (context, snapshot) {
          if (snapshot
              .connectionState !=
              ConnectionState.done) {
            return const _LoadingScreen();
          }

          if (snapshot.hasError) {
            return _InitializationErrorScreen(
              error:
              snapshot.error,
              onRetry:
              retryInitialization,
            );
          }

          return const AuthGate();
        },
      ),
    );
  }
}

// ================================================================
// AUTH GATE
// ================================================================

class AuthGate
    extends StatelessWidget {
  const AuthGate({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return StreamBuilder<User?>(
      stream: context
          .read<AuthProvider>()
          .authStateChanges,
      builder:
          (context, snapshot) {
        if (snapshot
            .connectionState ==
            ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        if (snapshot.hasData) {
          return const MainShell();
        }

        return const LoginScreen();
      },
    );
  }
}

// ================================================================
// LOADING
// ================================================================

class _LoadingScreen
    extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons
                  .account_balance_wallet,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Expense Tracker',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight:
                FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              width: 32,
              height: 32,
              child:
              CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.green,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              'Loading...',
              style: TextStyle(
                color:
                Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// INITIALIZATION ERROR
// ================================================================

class _InitializationErrorScreen
    extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const _InitializationErrorScreen({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(0xFF121212),
      body: SafeArea(
        child: Center(
          child:
          SingleChildScrollView(
            padding:
            const EdgeInsets.all(
              24,
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 70,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'App Initialization Failed',
                  textAlign:
                  TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                const Text(
                  'Authentication, ExpenseProvider or UserProvider could not be initialized.',
                  textAlign:
                  TextAlign.center,
                  style: TextStyle(
                    color:
                    Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width:
                  double.infinity,
                  padding:
                  const EdgeInsets.all(
                    16,
                  ),
                  decoration:
                  BoxDecoration(
                    color: Colors.red
                        .withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                    border:
                    Border.all(
                      color: Colors.red
                          .withValues(
                        alpha: 0.35,
                      ),
                    ),
                  ),
                  child:
                  SelectableText(
                    error?.toString() ??
                        'Unknown error',
                    style:
                    const TextStyle(
                      color:
                      Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                SizedBox(
                  width:
                  double.infinity,
                  height: 48,
                  child:
                  ElevatedButton.icon(
                    onPressed:
                    onRetry,
                    icon:
                    const Icon(
                      Icons.refresh,
                    ),
                    label:
                    const Text(
                      'Retry',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}