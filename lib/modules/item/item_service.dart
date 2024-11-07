// modules/item/item_service.dart
import 'package:swiftstock_app/services/service_locator.dart';
import 'package:swiftstock_app/services/database_service.dart';
import 'item_model.dart';

class ItemService {
  final DatabaseService _dbService = locator<DatabaseService>();

  Future<List<Item>> getItems() async {
    if (_dbService == null) {
      return [];
    }
    return await _dbService.getAllItems();
  }

  Future<void> addItem(Item item) async {
    if (_dbService == null) {
      // Handle the case when database is not available
      return;
    }
    await _dbService.insertItem(item);
  }

  // Other methods...
}
