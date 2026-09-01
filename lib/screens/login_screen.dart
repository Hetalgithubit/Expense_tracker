import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'main_shell.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final _formKey =
  GlobalKey<FormState>();

  final _emailController =
  TextEditingController();

  final _passwordController =
  TextEditingController();

  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth =
    context.read<AuthProvider>();

    final user = await auth.login(
      email:
      _emailController.text.trim(),
      password:
      _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (user != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const MainShell(),
        ),
            (route) => false,
      );

      return;
    }

    final error =
        context.read<AuthProvider>().errorMessage;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );
    }
  }

  Future<void> _forgotPassword() async {
    final email =
    _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter your email first.',
          ),
        ),
      );
      return;
    }

    final auth =
    context.read<AuthProvider>();

    await auth.sendPasswordResetEmail(
      email,
    );

    if (!mounted) {
      return;
    }

    final error = auth.errorMessage;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset email sent.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth =
    context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons
                        .account_balance_wallet,
                    size: 80,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Expense Tracker',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Login to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 35),
                  TextFormField(
                    controller:
                    _emailController,
                    keyboardType:
                    TextInputType.emailAddress,
                    textInputAction:
                    TextInputAction.next,
                    decoration:
                    const InputDecoration(
                      labelText: 'Email',
                      hintText:
                      'Enter your email',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                      ),
                    ),
                    validator: (value) {
                      final email =
                          value?.trim() ?? '';

                      if (email.isEmpty) {
                        return 'Please enter your email.';
                      }

                      if (!RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(email)) {
                        return 'Enter a valid email.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller:
                    _passwordController,
                    obscureText:
                    _hidePassword,
                    textInputAction:
                    TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!auth.isLoading) {
                        _login();
                      }
                    },
                    decoration:
                    InputDecoration(
                      labelText: 'Password',
                      hintText:
                      'Enter your password',
                      prefixIcon:
                      const Icon(
                        Icons.lock_outline,
                      ),
                      suffixIcon:
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _hidePassword =
                            !_hidePassword;
                          });
                        },
                        icon: Icon(
                          _hidePassword
                              ? Icons
                              .visibility_outlined
                              : Icons
                              .visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return 'Please enter your password.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment:
                    Alignment.centerRight,
                    child: TextButton(
                      onPressed:
                      auth.isLoading
                          ? null
                          : _forgotPassword,
                      child: const Text(
                        'Forgot Password?',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                      auth.isLoading
                          ? null
                          : _login,
                      child: auth.isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        'Login',
                        style: TextStyle(
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const SignupScreen(),
                            ),
                          );
                        },
                        child:
                        const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}