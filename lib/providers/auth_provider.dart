import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  User? _user;

  bool _isLoading = false;

  String? _errorMessage;

  User? get user => _user;

  String? get userId =>
      _user?.uid;

  String? get email =>
      _user?.email;

  String? get displayName =>
      _user?.displayName;

  bool get isLoggedIn =>
      _user != null;

  bool get isLoading =>
      _isLoading;

  String? get errorMessage =>
      _errorMessage;

  Stream<User?> get authStateChanges =>
      _auth.authStateChanges();


  // INIT


  Future<void> init() async {
    _user =
        _auth.currentUser;

    notifyListeners();
  }


  // SIGN UP


  Future<User?> signUp({
    required String name,
    required String mobileNumber,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final credential =
      await _auth
          .createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final newUser =
          credential.user;

      if (newUser == null) {
        _errorMessage =
        'Unable to create account.';

        notifyListeners();

        return null;
      }

      // Firebase display name
      await newUser
          .updateDisplayName(
        name.trim(),
      );

      // Firestore profile
      await _firestore
          .collection('users')
          .doc(newUser.uid)
          .set({
        'uid': newUser.uid,
        'name': name.trim(),
        'mobileNumber':
        mobileNumber.trim(),
        'email': email.trim(),
        'createdAt':
        FieldValue.serverTimestamp(),
        'updatedAt':
        FieldValue.serverTimestamp(),
      });

      await newUser.reload();

      _user =
          _auth.currentUser;

      /*
       IMPORTANT:
       Signup complete but user should
       login from Login screen.
      */

      await _auth.signOut();

      _user = null;

      notifyListeners();

      return newUser;
    } on FirebaseAuthException catch (e) {
      _errorMessage =
          _getAuthErrorMessage(e);

      notifyListeners();

      return null;
    } on FirebaseException catch (e) {
      _errorMessage =
          e.message ??
              'Unable to save user profile.';

      notifyListeners();

      return null;
    } catch (e) {
      _errorMessage =
      'Something went wrong.';

      notifyListeners();

      return null;
    } finally {
      _setLoading(false);
    }
  }


  // LOGIN


  Future<User?> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final credential =
      await _auth
          .signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _user =
          credential.user;

      notifyListeners();

      return _user;
    } on FirebaseAuthException catch (e) {
      _errorMessage =
          _getAuthErrorMessage(e);

      notifyListeners();

      return null;
    } catch (e) {
      _errorMessage =
      'Something went wrong.';

      notifyListeners();

      return null;
    } finally {
      _setLoading(false);
    }
  }


  // LOGOUT

  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await _auth.signOut();

      _user = null;

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _errorMessage =
          _getAuthErrorMessage(e);

      notifyListeners();
    } catch (e) {
      _errorMessage =
      'Unable to logout.';

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }


  // PASSWORD RESET


  Future<void>
  sendPasswordResetEmail(
      String email,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      await _auth
          .sendPasswordResetEmail(
        email: email.trim(),
      );
    } on FirebaseAuthException catch (e) {
      _errorMessage =
          _getAuthErrorMessage(e);

      notifyListeners();
    } catch (e) {
      _errorMessage =
      'Unable to send password reset email.';

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }


  // USER PROFILE


  Future<Map<String, dynamic>?>
  getUserProfile() async {
    final uid =
        _user?.uid;

    if (uid == null) {
      return null;
    }

    final snapshot =
    await _firestore
        .collection('users')
        .doc(uid)
        .get();

    if (!snapshot.exists) {
      return null;
    }

    return snapshot.data();
  }


  // UPDATE PROFILE

  Future<void> updateUserProfile({
    required String name,
    required String mobileNumber,
  }) async {
    final uid =
        _user?.uid;

    if (uid == null) {
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set(
        {
          'uid': uid,
          'name': name.trim(),
          'mobileNumber':
          mobileNumber.trim(),
          'email': _user?.email,
          'updatedAt':
          FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      await _user
          ?.updateDisplayName(
        name.trim(),
      );

      await _user?.reload();

      _user =
          _auth.currentUser;

      notifyListeners();
    } on FirebaseException catch (e) {
      _errorMessage =
          e.message ??
              'Unable to update profile.';

      notifyListeners();
    } catch (e) {
      _errorMessage =
      'Unable to update profile.';

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }


  // ERROR


  void clearError() {
    _clearError();
    notifyListeners();
  }

  void _setLoading(
      bool value,
      ) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  String _getAuthErrorMessage(
      FirebaseAuthException e,
      ) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-not-found':
        return 'No account found with this email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';

      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';

      default:
        return e.message ??
            'Authentication failed.';
    }
  }
}