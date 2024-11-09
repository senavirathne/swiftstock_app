// services/null_database_service.dart
import 'package:swiftstock_app/modules/activity/activity_model.dart';
import 'package:swiftstock_app/modules/item/item_model.dart';
import 'package:swiftstock_app/modules/transaction/transaction_model.dart';
import 'database_service.dart';


class NullDatabaseService implements DatabaseService {
  @override
  Future<void> saveSetting(String key, dynamic value) async {
    // No operation
  }

  @override
  Future<dynamic> getSetting(String key) async {
    // Return null or default value
    return null;
  }

  @override
  Future<void> deleteItem(int itemId) async {
    // No operation
  }

  @override
  Future<int> insertActivity(Activity activity) async {
    // Return a default value
    return -1;
  }

  @override
  Future<List<Activity>> getAllActivities() async {
    // Return an empty list
    return [];
  }

  @override
  Future<void> clearDatabase() async {
    // No operation
  }

  @override
  Future<List<Item>> getItemsByEnglishName(String englishName) async {
    // Return an empty list
    return [];
  }

  @override
  Future<void> updateItem(Item item) async {
    // No operation
  }

  @override
  Future<List<double>> getMostUsedQuantitiesForEnglishName(
      String englishName) async {
    // Return an empty list
    return [];
  }

  @override
  Future<int> insertItem(Item item) async {
    // Return a default value
    return -1;
  }

  @override
  Future<List<Item>> getAllItems() async {
    // Return an empty list
    return [];
  }

  @override
  Future<void> updateItemFrequency(int itemId) async {
    // No operation
  }

  @override
  Future<int> insertTransaction(TransactionModel transaction) async {
    // Return a default value
    return -1;
  }

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    // Return an empty list
    return [];
  }
  
  @override
  // TODO: implement database
  get database => throw UnimplementedError();
  
  @override
  Future<void> init() {
    // TODO: implement init
    throw UnimplementedError();
  }
  
  @override
  Future<void> updateItemQuantityAfterSale(int itemId, double quantitySold) {
    // TODO: implement updateItemQuantityAfterSale
    throw UnimplementedError();
  }
  
  @override
  // TODO: implement sharedInstance
  get sharedInstance => throw UnimplementedError();
}
