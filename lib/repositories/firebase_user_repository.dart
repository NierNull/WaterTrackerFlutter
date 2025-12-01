import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart'; 
import 'user_repository.dart'; 
import '../models/user_settings_model.dart';

class FirebaseUserRepository implements UserRepository {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  
  @override
  Future<UserSettings> getUserSettings(String userId) async {
    final docRef = _db.collection('users').doc(userId); 
    final doc = await docRef.get();

    if (doc.exists) {

      return UserSettings.fromFirestore(doc);
    } else {

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
 
        throw Exception('User is not authenticated but settings are being fetched.');
      }

      final defaultSettings = UserSettings(
        uid: userId,
        email: user.email ?? '',
        displayName: user.displayName ?? 'New User',
        age: 25,
        gender: Gender.other,
        weight: 60,
        height: 160,
        wakeTime: const TimeOfDay(hour: 8, minute: 0),
        sleepTime: const TimeOfDay(hour: 22, minute: 0),
        climate: 'normal',
        profileImageUrl: user.photoURL, 
        dailyGoal: 2100, 
      );


      await docRef.set(defaultSettings.toFirestore());
      

      return defaultSettings;
    }
  }

  @override
  Future<void> updateUserSettings(UserSettings settings) {
    return _db
        .collection('users')
        .doc(settings.uid)
        .set(settings.toFirestore());
  }

  @override
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      final ref = _storage.ref().child("users/$userId/profile_image.jpg");
      
      await ref.putFile(imageFile);

      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}