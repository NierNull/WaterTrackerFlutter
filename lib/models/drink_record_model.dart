import 'package:cloud_firestore/cloud_firestore.dart';

class DrinkRecord {
  final String? id;
  final int amount;
  final String drinkName;
  final Timestamp timestamp;

  DrinkRecord({
    this.id,
    required this.amount,
    required this.drinkName,
    required this.timestamp,
  });

  factory DrinkRecord.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return DrinkRecord(
      id: doc.id,
      amount: data['amount'],
      drinkName: data['drinkName'],
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'drinkName': drinkName,
      'timestamp': timestamp,
    };
  }
}