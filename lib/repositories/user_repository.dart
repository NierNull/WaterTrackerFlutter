import 'dart:io';
import '../models/user_settings_model.dart';

abstract class UserRepository {
  Future<UserSettings> getUserSettings(String userId);
  Future<void> updateUserSettings(UserSettings settings);
  Future<String> uploadProfileImage(String userId, File imageFile); // Для кроку 6
}