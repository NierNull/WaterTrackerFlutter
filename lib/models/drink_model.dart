import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Drink {
  final String id;
  final String name;
  final String iconName; 
  final double waterPercentage;
  final String description;

  Drink({
    required this.id,
    required this.name,
    required this.iconName,
    required this.waterPercentage,
    required this.description,
  });

  factory Drink.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Drink(
      id: doc.id,
      name: data['name'],
      iconName: data['iconName'],
      waterPercentage: (data['waterPercentage'] as num).toDouble(),
      description: data['description'],
    );
  }

  IconData get icon {
    switch (iconName) {
      case 'local_drink_outlined': return Icons.local_drink_outlined;
      case 'coffee_outlined': return Icons.coffee_outlined;
      case 'emoji_food_beverage_outlined': return Icons.emoji_food_beverage_outlined;
      default: return Icons.pets; 
    }
  }
}