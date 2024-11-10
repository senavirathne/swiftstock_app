// services/database_service.dart
import 'package:swiftstock_app/modules/item/item_model.dart';
import 'package:swiftstock_app/modules/activity/activity_model.dart';
import 'package:swiftstock_app/modules/transaction/transaction_model.dart';

abstract class DatabaseService {
  // DatabaseService get sharedInstance;
  Future<void> init();
  Future<void> updateItemQuantityAfterSale(int itemId, double quantitySold);

// lib/services/database_service.dart

  // Settings
  Future<void> saveSetting(String key, dynamic value);
  Future<dynamic> getSetting(String key);

  // Item operations
  Future<int> insertItem(Item item);
  Future<void> updateItem(Item item);
  Future<void> deleteItem(int itemId);
  Future<List<Item>> getAllItems();
  Future<List<Item>> getItemsByEnglishName(String englishName);
  Future<void> updateItemFrequency(int itemId);

  // Activity operations
  Future<int> insertActivity(Activity activity);
  Future<List<Activity>> getAllActivities();

  // Transaction operations
  Future<int> insertTransaction(TransactionModel transaction);
  Future<List<TransactionModel>> getAllTransactions();

  // Utility operations
  Future<void> clearDatabase();
  Future<List<double>> getMostUsedQuantitiesForEnglishName(String englishName);

}
