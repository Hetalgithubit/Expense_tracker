import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({
    super.key,
  });

  @override
  State<SignupScreen> createState() =>
      _SignupScreenState();
}

class _SignupScreenState
    extends State<SignupScreen> {
  final _formKey =
  GlobalKey<FormState>();

  final _nameController =
  TextEditingController();

  final _mobileController =
  TextEditingController();

  final _emailController =
  TextEditingController();

  final _passwordController =
  TextEditingController();

  bool _hidePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth =
    context.read<AuthProvider>();

    final user = await auth.signUp(
      name: _nameController.text.trim(),
      mobileNumber:
      _mobileController.text.trim(),
      email: _emailController.text.trim(),
      password:
      _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created successfully.',
          ),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const LoginScreen(),
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

  @override
  Widget build(BuildContext context) {
    final auth =
    context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.account_circle,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Create your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _nameController,
                  textInputAction:
                  TextInputAction.next,
                  decoration:
                  const InputDecoration(
                    labelText: 'Name',
                    hintText:
                    'Enter your name',
                    prefixIcon: Icon(
                      Icons.person_outline,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter your name.';
                    }

                    if (value.trim().length <
                        2) {
                      return 'Name is too short.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller:
                  _mobileController,
                  keyboardType:
                  TextInputType.phone,
                  textInputAction:
                  TextInputAction.next,
                  maxLength: 10,
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Mobile Number',
                    hintText:
                    'Enter 10 digit mobile number',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                    ),
                    counterText: '',
                  ),
                  validator: (value) {
                    final mobile =
                        value?.trim() ?? '';

                    if (mobile.isEmpty) {
                      return 'Please enter your mobile number.';
                    }

                    if (!RegExp(
                      r'^[0-9]{10}$',
                    ).hasMatch(mobile)) {
                      return 'Enter a valid 10 digit mobile number.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                      return 'Enter a valid email address.';
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
                      _signup();
                    }
                  },
                  decoration:
                  InputDecoration(
                    labelText: 'Password',
                    hintText:
                    'Minimum 6 characters',
                    prefixIcon: const Icon(
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
                      return 'Please enter a password.';
                    }

                    if (value.length < 6) {
                      return 'Password must be at least 6 characters.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                    auth.isLoading
                        ? null
                        : _signup,
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
                      'Create Account',
                      style: TextStyle(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const LoginScreen(),
                          ),
                        );
                      },
                      child:
                      const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}