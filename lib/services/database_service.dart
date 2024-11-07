// services/database_service.dart
import 'package:swiftstock_app/modules/item/item_model.dart';
abstract class DatabaseService {
  Future<void> init();
  Future<void> clearDatabase();
  Future<int> insertItem(Item item);
  Future<List<Item>> getAllItems();
  // Other database methods...
}
