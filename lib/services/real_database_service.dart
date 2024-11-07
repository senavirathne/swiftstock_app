// lib/services/real_database_service.dart

import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart'; // or sembast_web.dart for web
import 'package:path_provider/path_provider.dart'; // Only for mobile platforms
import 'package:swiftstock_app/modules/item/item_model.dart';
import 'database_service.dart';

class RealDatabaseService implements DatabaseService {
  Database? _db;
  final _itemStore = intMapStoreFactory.store('items');

  @override
  Future<void> init() async {
    if (_db != null) return;

    // Initialize the database (adjust for web or mobile)
    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    String dbPath = '${dir.path}/app.db';
    _db = await databaseFactoryIo.openDatabase(dbPath);
  }

  @override
  Future<void> clearDatabase() async {
    await _itemStore.delete(_db!);
  }

  @override
  Future<int> insertItem(Item item) async {
    await init();
    int key = await _itemStore.add(_db!, item.toMap());
    return key;
  }

  @override
  Future<List<Item>> getAllItems() async {
    await init();
    var records = await _itemStore.find(_db!);
    List<Item> items = records.map((snapshot) {
      var item = Item.fromMap(snapshot.value);
      item.id = snapshot.key;
      return item;
    }).toList();
    return items;
  }
}
