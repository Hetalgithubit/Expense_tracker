import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';

import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth =
      firebase_auth.FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  User? _selectedUser;

  User? get selectedUser => _selectedUser;

  List<User> get users {
    if (_selectedUser == null) {
      return const [];
    }

    return [_selectedUser!];
  }

  bool get hasSelectedUser =>
      _selectedUser != null;

  String? get firebaseUserId =>
      _auth.currentUser?.uid;




  Future<void> init() async {
    final firebaseUser =
        _auth.currentUser;

    if (firebaseUser == null) {
      _selectedUser = null;
      notifyListeners();
      return;
    }

    await loadCurrentUser();
  }




  Future<void> loadCurrentUser() async {
    final firebaseUser =
        _auth.currentUser;

    if (firebaseUser == null) {
      _selectedUser = null;
      notifyListeners();
      return;
    }

    final uid = firebaseUser.uid;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      final data = snapshot.data();

      final now = DateTime.now();

      final name =
          data?['name']?.toString() ??
              firebaseUser.displayName ??
              'User';

      final mobileNumber =
          data?['mobileNumber']?.toString() ??
              '';

      DateTime createdAt = now;

      final createdValue =
      data?['createdAt'];

      if (createdValue is Timestamp) {
        createdAt =
            createdValue.toDate();
      }

      _selectedUser = User(
        id: uid,
        name: name,
        mobileNumber: mobileNumber,
        createdAt: createdAt,
        updatedAt: now,
      );

      notifyListeners();
    } catch (e) {
      debugPrint(
        'UserProvider Firebase load error: $e',
      );

      final now = DateTime.now();

      _selectedUser = User(
        id: uid,
        name:
        firebaseUser.displayName ??
            'User',
        mobileNumber: '',
        createdAt: now,
        updatedAt: now,
      );

      notifyListeners();
    }
  }




  void selectUser(User user) {
    final firebaseUser =
        _auth.currentUser;

    if (firebaseUser == null) {
      return;
    }

    if (user.id != firebaseUser.uid) {
      debugPrint(
        'Blocked selecting another user.',
      );
      return;
    }

    _selectedUser = user;

    notifyListeners();
  }

  void selectUserById(String userId) {
    final firebaseUser =
        _auth.currentUser;

    if (firebaseUser == null) {
      return;
    }

    if (userId != firebaseUser.uid) {
      return;
    }

    loadCurrentUser();
  }




  Future<void> updateUser(User user) async {
    final firebaseUser =
        _auth.currentUser;

    if (firebaseUser == null) {
      return;
    }

    final uid = firebaseUser.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .set(
      {
        'uid': uid,
        'name': user.name.trim(),
        'mobileNumber':
        user.mobileNumber.trim(),
        'email': firebaseUser.email,
        'updatedAt':
        FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await firebaseUser
        .updateDisplayName(
      user.name.trim(),
    );

    await firebaseUser.reload();

    await loadCurrentUser();
  }





  Future<void> addUser({
    required String name,
    required String mobileNumber,
  }) async {
    final firebaseUser =
        _auth.currentUser;

    if (firebaseUser == null) {
      return;
    }

    final uid = firebaseUser.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .set(
      {
        'uid': uid,
        'name': name.trim(),
        'mobileNumber':
        mobileNumber.trim(),
        'email': firebaseUser.email,
        'updatedAt':
        FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await firebaseUser
        .updateDisplayName(
      name.trim(),
    );

    await firebaseUser.reload();

    await loadCurrentUser();
  }




  Future<void> deleteUser(
      String userId) async {
    final firebaseUser =
        _auth.currentUser;

    if (firebaseUser == null) {
      return;
    }

    if (userId != firebaseUser.uid) {
      return;
    }

    debugPrint(
      'User deletion blocked. '
          'Use Firebase account deletion separately.',
    );
  }




  Future<void> refreshUsers() async {
    await loadCurrentUser();
  }




  void clearUser() {
    _selectedUser = null;
    notifyListeners();
  }
}