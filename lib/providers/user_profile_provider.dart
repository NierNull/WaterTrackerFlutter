import 'package:flutter/material.dart';
import '../models/user_settings_model.dart';
import '../repositories/user_repository.dart';
import '../repositories/firebase_user_repository.dart'; 
import 'dart:io';

class UserProfileProvider extends ChangeNotifier {
  final UserRepository _userRepo = FirebaseUserRepository();
  final String? _userId; 

  UserSettings? userSettings;
  bool isLoading = false;

  int get dailyGoal => userSettings?.dailyGoal ?? 2000;


  UserProfileProvider(this._userId, [UserProfileProvider? previous]) {
    if (previous != null) {
      userSettings = previous.userSettings;
      isLoading = previous.isLoading;
    }
    
    if (_userId != null && userSettings == null) {
      fetchUserSettings();
    }
  }

  int _calculateDailyGoal(int weight, String climate, int age) {

    double goal = weight * 35.0;

    if (climate == 'hot') {
      goal += 500;
    }

    if (age > 55) {
      goal *= 0.9; 
    }

    return (goal / 50).round() * 50;
  }


  Future<void> fetchUserSettings() async {
    if (_userId == null) return;
    isLoading = true;
    notifyListeners();
    try {
      userSettings = await _userRepo.getUserSettings(_userId);
    } catch (e) {
      print(e); 
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> updateUserSettings(UserSettings settings) async {
    if (_userId == null) return;
    isLoading = true;
    notifyListeners();
    
    try {

      final calculatedGoal = _calculateDailyGoal(
        settings.weight,
        settings.climate,
        settings.age,
      );

  
      final settingsWithGoal = UserSettings(
        uid: settings.uid, 
        email: settings.email, 
        displayName: settings.displayName, 
        age: settings.age, 
        gender: settings.gender, 
        weight: settings.weight, 
        height: settings.height, 
        wakeTime: settings.wakeTime, 
        sleepTime: settings.sleepTime, 
        climate: settings.climate, 
        profileImageUrl: settings.profileImageUrl,
        dailyGoal: calculatedGoal, 
      );

      await _userRepo.updateUserSettings(settingsWithGoal);
      userSettings = settingsWithGoal; 
    } catch (e) {
      print(e);
    }
    isLoading = false;
    notifyListeners();
  }


  Future<void> updateProfileImage(File imageFile) async {
    if (_userId == null || userSettings == null) return;
    isLoading = true;
    notifyListeners();
    
    try {
      final downloadUrl = await _userRepo.uploadProfileImage(_userId, imageFile);

      final updatedSettings = UserSettings(
        uid: userSettings!.uid,
        email: userSettings!.email,
        displayName: userSettings!.displayName,
        age: userSettings!.age,
        gender: userSettings!.gender,
        weight: userSettings!.weight,
        height: userSettings!.height,
        wakeTime: userSettings!.wakeTime,
        sleepTime: userSettings!.sleepTime,
        climate: userSettings!.climate,
        profileImageUrl: downloadUrl, 
        dailyGoal: userSettings!.dailyGoal, 
      );

      
      await _userRepo.updateUserSettings(updatedSettings);
      
      userSettings = updatedSettings;
      
    } catch (e) {
      print(e);
    }
    
    isLoading = false;
    notifyListeners();
  }
}