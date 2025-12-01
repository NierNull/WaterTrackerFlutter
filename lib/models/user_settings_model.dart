import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum Gender { male, female, other }

class UserSettings {
  final String uid;
  final String email;
  final String displayName;
  final int age;
  final Gender gender;
  final int weight;
  final int height;
  final TimeOfDay wakeTime;
  final TimeOfDay sleepTime;
  final String climate;
  final String? profileImageUrl;
  final int dailyGoal;

  UserSettings({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.wakeTime,
    required this.sleepTime,
    required this.climate,
    this.profileImageUrl,
    required this.dailyGoal,
  });

  static TimeOfDay _timeFromString(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
  
  static String _timeToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  factory UserSettings.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserSettings(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      age: data['age'] ?? 20,
      gender: (data['gender'] == 'male') ? Gender.male 
            : (data['gender'] == 'female') ? Gender.female : Gender.other,
      weight: data['weight'] ?? 60,
      height: data['height'] ?? 160,
      wakeTime: _timeFromString(data['wakeTime'] ?? '08:00'),
      sleepTime: _timeFromString(data['sleepTime'] ?? '22:00'),
      climate: data['climate'] ?? 'normal',
      profileImageUrl: data['profileImageUrl'],
      dailyGoal: data['dailyGoal'] ?? 2000,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'age': age,
      'gender': gender.name, 
      'weight': weight,
      'height': height,
      'wakeTime': _timeToString(wakeTime),
      'sleepTime': _timeToString(sleepTime),
      'climate': climate,
      'profileImageUrl': profileImageUrl,
      'dailyGoal': dailyGoal,
    };
  }
}