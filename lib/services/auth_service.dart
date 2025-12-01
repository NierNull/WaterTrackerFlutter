import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signUp({
      required String name,
      required String email,
      required String password,
    }) async {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(name.trim());
        await user.reload();
      }

      return userCredential;
    }

    Future<UserCredential?> signInWithEmailAndPassword(
        BuildContext context, String email, String password) async {
      try {
        return await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
      } on FirebaseAuthException catch (e) {
        _showError(context, e);
        return null;
      }
    }

  Future<UserCredential?> createUserWithEmailAndPassword(
      BuildContext context, String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name.trim());
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      _showError(context, e);
      return null;
    }
  }

  void _showError(BuildContext context, FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'invalid-email':
        message = 'Invalid email format';
        break;
      case 'user-not-found':
        message = 'User not found';
        break;
      case 'wrong-password':
        message = 'Incorrect password';
        break;
      case 'email-already-in-use':
        message = 'Email already in use';
        break;
      case 'weak-password':
        message = 'Password is too weak';
        break;
      default:
        message = 'Unexpected error: ${e.message}';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
