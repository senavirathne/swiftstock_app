// services/null_database_service.dart
import 'package:swiftstock_app/modules/item/item_model.dart';
import 'database_service.dart';
class NullDatabaseService implements DatabaseService {
  @override
  Future<void> init() async {
    // No operation
  }

  @override
  Future<void> clearDatabase() async {
    // No operation
  }

  @override
  Future<int> insertItem(Item item) async {
    // Return a default value or throw an exception
    return -1;
  }

  @override
  Future<List<Item>> getAllItems() async {
    // Return an empty list
    return [];
  }
}
