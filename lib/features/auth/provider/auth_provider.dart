import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _userModel;
  bool _isLoading = false;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;

  // Automatically check if user is already logged in on startup
  AuthProvider() {
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _fetchUserData(currentUser.uid);
    }
  }

  Future<void> _fetchUserData(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      _userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      notifyListeners();
    }
  }

  // Sign Up Function
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    try {
      // Create user in Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile model
      _userModel = UserModel(
        uid: credential.user!.uid,
        email: email,
        displayName: name,
      );

      // Save user to Cloud Firestore
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(_userModel!.toMap());

      _setLoading(false);
      return null; // Return null if successful
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message; // Return friendly error string
    } catch (e) {
      _setLoading(false);
      return "An unexpected error occurred. Please try again.";
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _fetchUserData(credential.user!.uid);
      _setLoading(false);
      return null; // Return null means login was completely successful!
    } on FirebaseAuthException catch (e) {
      _setLoading(false);

      // Map Firebase machine codes to clear, user-friendly snackbar sentences
      switch (e.code) {
        case 'user-not-found':
          return 'This email address is not registered. Please sign up first.';
        case 'wrong-password':
          return 'The password you entered is incorrect. Please try again.';
        case 'invalid-email':
          return 'The email format is malformed or invalid.';
        case 'user-disabled':
          return 'This user account has been disabled by an administrator.';
        case 'invalid-credential':
          return 'User not found with this Credential.';
        default:
          return e.message ?? 'Authentication failed. Please try again.';
      }
    } catch (e) {
      _setLoading(false);
      return "Login failed. Check your internet connection and try again.";
    }
  }

  // Sign Out Function
  Future<void> signOut() async {
    await _auth.signOut();
    _userModel = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}