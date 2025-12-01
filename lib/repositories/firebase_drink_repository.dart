import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/drink_model.dart';
import '../models/drink_record_model.dart';
import 'drink_repository.dart';


class FirebaseDrinkRepository implements DrinkRepository {
  final _db = FirebaseFirestore.instance;

  @override
  Future<List<Drink>> getDrinkDefinitions() async {
    try {
      final snapshot = await _db.collection('drink_definitions').get();
      return snapshot.docs.map((doc) => Drink.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error getting drink definitions: $e");
      rethrow;
    }
  }


  @override
  Stream<List<DrinkRecord>> getDrinkRecordsStream(String userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final startTimestamp = Timestamp.fromDate(startOfDay);
    final endTimestamp = Timestamp.fromDate(endOfDay);
    return _db
        .collection('users')
        .doc(userId)
        .collection('drink_records')
        .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
        .where('timestamp', isLessThanOrEqualTo: endTimestamp)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => DrinkRecord.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<void> addDrinkRecord(String userId, DrinkRecord record) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('drink_records')
        .add(record.toFirestore());
  }



  @override
  Future<void> updateDrinkRecord(String userId, DrinkRecord record) {

    if (record.id == null) {
      throw Exception("Record ID cannot be null for an update");
    }

    return _db
        .collection('users')
        .doc(userId)
        .collection('drink_records')
        .doc(record.id)
        .update(record.toFirestore());

  }



  @override
  Future<void> deleteDrinkRecord(String userId, String recordId) {

    return _db
        .collection('users')
        .doc(userId)
        .collection('drink_records')
        .doc(recordId)
        .delete();
  }
}