import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/expense_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider =
    context.watch<UserProvider>();

    return Scaffold(
      backgroundColor:
      const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Select User',
        ),
        backgroundColor:
        const Color(0xFF121212),
        foregroundColor:
        Colors.white,
        elevation: 0,
      ),
      body: userProvider.users.isEmpty
          ? const _EmptyUserView()
          : ListView.builder(
        padding:
        const EdgeInsets.all(
          16,
        ),
        itemCount:
        userProvider.users.length,
        itemBuilder:
            (context, index) {
          final user =
          userProvider
              .users[index];

          final isSelected =
              userProvider
                  .selectedUser
                  ?.id ==
                  user.id;

          return _UserCard(
            user: user,
            isSelected:
            isSelected,
            onTap: () async {
              final expenseProvider =
              context.read<
                  ExpenseProvider>();

              userProvider
                  .selectUser(user);

              await expenseProvider
                  .setUser(user.id);
            },
            onDelete: () {
              _showDeleteDialog(
                context,
                user,
              );
            },
          );
        },
      ),
      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: () {
          _showAddUserDialog(
            context,
          );
        },
        backgroundColor:
        AppColors.green,
        foregroundColor:
        Colors.black,
        icon: const Icon(
          Icons.person_add,
        ),
        label: const Text(
          'Add User',
        ),
      ),
    );
  }

  void _showAddUserDialog(
      BuildContext context,
      ) {
    final nameController =
    TextEditingController();

    final mobileController =
    TextEditingController();

    final formKey =
    GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
          const Color(0xFF1E1E1E),
          title: const Text(
            'Add User',
            style: TextStyle(
              color: Colors.white,
              fontWeight:
              FontWeight.w700,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                TextFormField(
                  controller:
                  nameController,
                  style:
                  const TextStyle(
                    color: Colors.white,
                  ),
                  decoration:
                  const InputDecoration(
                    labelText: 'Name',
                    prefixIcon:
                    Icon(
                      Icons.person,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value
                            .trim()
                            .isEmpty) {
                      return 'Enter name';
                    }

                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller:
                  mobileController,
                  keyboardType:
                  TextInputType.phone,
                  maxLength: 10,
                  style:
                  const TextStyle(
                    color: Colors.white,
                  ),
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Mobile Number',
                    prefixIcon:
                    Icon(
                      Icons.phone,
                    ),
                    counterText: '',
                  ),
                  validator: (value) {
                    final mobile =
                        value?.trim() ??
                            '';

                    if (mobile.isEmpty) {
                      return 'Enter mobile number';
                    }

                    if (mobile.length !=
                        10) {
                      return 'Enter valid 10 digit mobile number';
                    }

                    if (!RegExp(
                      r'^[0-9]+$',
                    ).hasMatch(mobile)) {
                      return 'Enter numbers only';
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey
                    .currentState!
                    .validate()) {
                  return;
                }

                await context
                    .read<UserProvider>()
                    .addUser(
                  name:
                  nameController
                      .text,
                  mobileNumber:
                  mobileController
                      .text,
                );

                if (dialogContext
                    .mounted) {
                  Navigator.pop(
                    dialogContext,
                  );
                }
              },
              child: const Text(
                'Save User',
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(
      BuildContext context,
      User user,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
          const Color(0xFF1E1E1E),
          title: const Text(
            'Delete User?',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: Text(
            'Delete ${user.name} and all expenses linked to this user?',
            style:
            const TextStyle(
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                Colors.red,
                foregroundColor:
                Colors.white,
              ),
              onPressed: () async {
                await context
                    .read<UserProvider>()
                    .deleteUser(
                  user.id,
                );

                if (dialogContext
                    .mounted) {
                  Navigator.pop(
                    dialogContext,
                  );
                }
              },
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _UserCard
    extends StatelessWidget {
  final User user;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),
      color: isSelected
          ? AppColors.green
          .withOpacity(0.12)
          : const Color(0xFF1E1E1E),
      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        side: BorderSide(
          color: isSelected
              ? AppColors.green
              : Colors.white12,
          width:
          isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor:
          AppColors.green
              .withOpacity(
            0.15,
          ),
          child: const Icon(
            Icons.person,
            color:
            AppColors.green,
            size: 28,
          ),
        ),
        title: Text(
          user.name,
          style:
          const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight:
            FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding:
          const EdgeInsets.only(
            top: 5,
          ),
          child: Text(
            user.mobileNumber,
            style:
            const TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color:
                AppColors.green,
              ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline,
                color:
                Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyUserView
    extends StatelessWidget {
  const _EmptyUserView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.white
                  .withOpacity(0.25),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'No Users Added',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight:
                FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const Text(
              'Add a user to start managing expenses separately.',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}