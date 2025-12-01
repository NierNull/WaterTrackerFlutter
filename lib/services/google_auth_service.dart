import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'password_dialog.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signInWithGoogleAndOfferPassword(BuildContext context) async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return null;

      final hasPasswordProvider =
          user.providerData.any((p) => p.providerId == 'password');

      if (hasPasswordProvider) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account already linked with password')),
        );
        return userCredential;
      }

      // показуємо діалог для введення паролю
      final password = await showPasswordSetupDialog(context, user.email);
      if (password == null || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password was not entered')),
        );
        return userCredential;
      }

      try {
        await user.linkWithCredential(
          EmailAuthProvider.credential(email: user.email!, password: password),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password linked successfully')),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error linking password: ${e.code}')),
        );
      }

      return userCredential;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: $e')),
      );
      return null;
    }
  }
}
