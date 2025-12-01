
import 'package:flutter/material.dart';

import '../repositories/firebase_drink_repository.dart';
import '../models/drink_record_model.dart';
import '../repositories/drink_repository.dart';


class DrinkRecordsProvider extends ChangeNotifier {
  final DrinkRepository _drinkRepo = FirebaseDrinkRepository();
  final String? _userId;

  Stream<List<DrinkRecord>>? recordsStream;

  DrinkRecordsProvider(this._userId, [DrinkRecordsProvider? previous]) {
    if (_userId != null) {

      getRecordsForDate(DateTime.now());
    }
  }

  void getRecordsForDate(DateTime date) {
    if (_userId == null) return;
    recordsStream = _drinkRepo.getDrinkRecordsStream(_userId, date);
    notifyListeners(); 
  }

  Future<void> addDrink(DrinkRecord record) async {
    if (_userId == null) return;
    try {
      await _drinkRepo.addDrinkRecord(_userId, record);

    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteDrink(String recordId) async {
    if (_userId == null) return;
    try {
      await _drinkRepo.deleteDrinkRecord(_userId, recordId);
    } catch (e) {
      print(e);
    }
  }
  Future<void> updateDrinkRecord(DrinkRecord record) async {

    if (_userId == null || record.id == null) return;
    try {

      await _drinkRepo.updateDrinkRecord(_userId, record);

    } catch (e) {
      print(e);
      rethrow; 
    }
  }
}