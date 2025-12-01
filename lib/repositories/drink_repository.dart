import '../models/drink_model.dart';
import '../models/drink_record_model.dart';

abstract class DrinkRepository {

  Future<List<Drink>> getDrinkDefinitions();


  Stream<List<DrinkRecord>> getDrinkRecordsStream(String userId, DateTime date);
  Future<void> addDrinkRecord(String userId, DrinkRecord record);
  Future<void> deleteDrinkRecord(String userId, String recordId);
  Future<void> updateDrinkRecord(String userId, DrinkRecord record);
}