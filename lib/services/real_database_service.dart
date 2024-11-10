// lib/services/real_database_service.dart

import 'package:sembast/sembast_io.dart'; 
import 'package:sembast_web/sembast_web.dart';
import 'package:path_provider/path_provider.dart'; // Only for mobile platforms
import 'package:swiftstock_app/modules/item/item_model.dart';
import 'package:swiftstock_app/modules/transaction/transaction_model.dart';
import 'package:swiftstock_app/modules/activity/activity_model.dart';
import 'database_service.dart';
import 'dart:async';
import 'package:swiftstock_app/providers/mod_quantities_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


class RealDatabaseService implements DatabaseService {
  // RealDatabaseService._privateConstructor();
  // static final RealDatabaseService _instance = RealDatabaseService._privateConstructor();
  // factory RealDatabaseService() => _instance;
  // // Expose the singleton instance with a different name to avoid conflict
  // DatabaseService get sharedInstance => _instance;
  Database? _database;
  final _itemStore = intMapStoreFactory.store('items');
  final _transactionStore = intMapStoreFactory.store('transactions');
  final _transactionItemStore = intMapStoreFactory.store('transaction_items');
  final _activityStore = intMapStoreFactory.store('activities');
  final _settingsStore = StoreRef<String, dynamic>('settings');

  @override
  Future<void> init() async {
    await database; // Ensures database initialization
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    DatabaseFactory dbFactory;
    String dbPath;

    if (kIsWeb) {
      dbFactory = databaseFactoryWeb;
      dbPath = 'item_transaction.db';
    } else {
      dbFactory = databaseFactoryIo;
      var dir = await getApplicationDocumentsDirectory();
      await dir.create(recursive: true);
      dbPath = '${dir.path}/item_transaction.db';
    }

    return await dbFactory.openDatabase(dbPath);
  }

  // Method to update item quantity after sale
  @override
  Future<void> updateItemQuantityAfterSale(int itemId, double quantitySold) async {
    try {
      Database db = await database;

      var finder = Finder(filter: Filter.byKey(itemId));
      var recordSnapshot = await _itemStore.findFirst(db, finder: finder);

      if (recordSnapshot != null) {
        Item item = Item.fromMap(recordSnapshot.value);
        item.id = recordSnapshot.key;

        // Reduce the quantity and ensure it doesn't go negative
        item.quantityLeft -= quantitySold;
        if (item.quantityLeft < 0) {
          item.quantityLeft = 0;
        }

        await _itemStore.update(db, item.toMap(), finder: finder);
      }
    } catch (e) {
      print('Error updating item quantity after sale: $e');
    }
  }

  @override
  Future<void> saveSetting(String key, dynamic value) async {
    Database db = await database;
    await _settingsStore.record(key).put(db, value);
  }

  @override
  Future<dynamic> getSetting(String key) async {
    Database db = await database;
    return await _settingsStore.record(key).get(db);
  }

  @override
  Future<void> deleteItem(int itemId) async {
    try {
      Database db = await database;
      var finder = Finder(filter: Filter.byKey(itemId));
      await _itemStore.delete(db, finder: finder);
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  @override
  Future<int> insertActivity(Activity activity) async {
    try {
      Database db = await database;
      var key = await _activityStore.add(db, activity.toMap());
      return key;
    } catch (e) {
      print('Error inserting activity: $e');
      return -1;
    }
  }

  @override
  Future<List<Activity>> getAllActivities() async {
    try {
      Database db = await database;
      var records = await _activityStore.find(db,
          finder: Finder(sortOrders: [
            SortOrder('dateTime', false), // Sort by dateTime descending
          ]));
      List<Activity> activities = records.map((snapshot) {
        var activity = Activity.fromMap(snapshot.value);
        activity.id = snapshot.key;
        return activity;
      }).toList();

      return activities;
    } catch (e) {
      print('Error retrieving activities: $e');
      return [];
    }
  }

  @override
  Future<void> clearDatabase() async {
    Database db = await database;
    await _itemStore.delete(db);
    // Uncomment the following lines if you want to clear transactions and transaction items
    await _transactionStore.delete(db);
    await _transactionItemStore.delete(db);
  }

  @override
  Future<List<Item>> getItemsByEnglishName(String englishName) async {
    final db = await database;
    final finder = Finder(filter: Filter.equals('englishName', englishName));
    final result = await _itemStore.find(db, finder: finder);
    return result.map((record) {
      var item = Item.fromMap(record.value);
      item.id = record.key;
      return item;
    }).toList();
  }
  @override
  Future<void> updateItem(Item item) async {
    try {
      Database db = await database;
      var finder = Finder(filter: Filter.byKey(item.id));
      await _itemStore.update(db, item.toMap(), finder: finder);
    } catch (e) {
      print('Error updating item: $e');
    }
  }

  Future<Item?> getItemById(int itemId) async {
    Database db = await database;
    var recordSnapshot = await _itemStore.record(itemId).get(db);
    if (recordSnapshot != null) {
      var item = Item.fromMap(recordSnapshot);
      item.id = itemId;
      return item;
    }
    return null;
  }

  @override
  Future<List<double>> getMostUsedQuantitiesForEnglishName(
      String englishName) async {
    Database db = await database;

    // Get items with the given englishName
    var itemFinder = Finder(filter: Filter.equals('englishName', englishName));
    var itemSnapshots = await _itemStore.find(db, finder: itemFinder);
    List<int> itemIds = itemSnapshots.map((snapshot) => snapshot.key).toList();

    if (itemIds.isEmpty) return [];

    // Get transaction items for these item IDs
    var transactionItemFinder =
        Finder(filter: Filter.inList('itemId', itemIds));
    var transactionItemSnapshots =
        await _transactionItemStore.find(db, finder: transactionItemFinder);

    // Create a map of quantity to frequency
    Map<double, int> quantityFrequency = {};

    for (var snapshot in transactionItemSnapshots) {
      var transactionItem = TransactionItem.fromMap(snapshot.value);
      double quantity = transactionItem.quantity;
      quantityFrequency[quantity] = (quantityFrequency[quantity] ?? 0) + 1;
    }

    // Sort quantities by frequency
    List<double> quantities = quantityFrequency.keys.toList();
    quantities.sort(
        (a, b) => quantityFrequency[b]!.compareTo(quantityFrequency[a]!));

    // Return top N quantities
    int numberOfModItems = ModQuantitiesProvider().numberOfModItems;
    if (quantities.length > numberOfModItems) {
      quantities = quantities.sublist(0, numberOfModItems);
    }

    return quantities;
  }

  @override
  Future<int> insertItem(Item item) async {
    try {
      Database db = await database;
      var key = await _itemStore.add(db, item.toMap());
      return key;
    } catch (e) {
      print('Error inserting item: $e');
      return -1;
    }
  }

  @override
  Future<List<Item>> getAllItems() async {
    try {
      Database db = await database;
      var records = await _itemStore.find(db);
      List<Item> items = records.map((snapshot) {
        var item = Item.fromMap(snapshot.value);
        item.id = snapshot.key;
        return item;
      }).toList();

      return items;
    } catch (e) {
      print('Error retrieving items: $e');
      return [];
    }
  }

  @override
  Future<int> insertTransaction(TransactionModel transaction) async {
    try {
      Database db = await database;

      // Insert the transaction (order) details
      var key = await _transactionStore.add(db, transaction.toMap());
      transaction.id = key; // Assign the transaction ID

      // Insert the individual items for the transaction
      for (var item in transaction.items) {
        item.transactionId = key; // Link each item to the transaction
        item.itemId = item.item?.id ?? item.itemId;
        await _transactionItemStore.add(db, item.toMap());

        // Update item quantity after sale
        if (item.item != null && item.item!.id != null) {
          await updateItemQuantityAfterSale(item.item!.id!, item.quantity);
        }
      }

      return key; // Return the transaction ID
    } catch (e) {
      print('Error inserting transaction: $e');
      return -1;
    }
  }

  @override
  Future<void> updateItemFrequency(int itemId) async {
    try {
      Database db = await database;
      var finder = Finder(filter: Filter.byKey(itemId));
      var recordSnapshot = await _itemStore.findFirst(db, finder: finder);

      if (recordSnapshot != null) {
        Item item = Item.fromMap(recordSnapshot.value);
        item.frequency += 1;
        await _itemStore.update(db, item.toMap(), finder: finder);
      }
    } catch (e) {
      print('Error updating item frequency: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    Database db = await database;
    var records = await _transactionStore.find(db);

    List<TransactionModel> transactions = [];
    for (var record in records) {
      TransactionModel transaction = TransactionModel.fromMap(record.value);
      transaction.id = record.key;

      // Fetch the associated items
      var finder = Finder(filter: Filter.equals('transactionId', transaction.id));
      var itemsSnapshot = await _transactionItemStore.find(db, finder: finder);

      transaction.items = [];
      for (var snapshot in itemsSnapshot) {
        var item = TransactionItem.fromMap(snapshot.value);
        item.id = snapshot.key;
        // Fetch the associated Item asynchronously
        if (item.itemId != null) {
          item.item = await getItemById(item.itemId!);
        }
        transaction.items.add(item);
      }

      transactions.add(transaction);
    }
    return transactions;
  }

  // Method to retrieve a transaction with all its items
  Future<TransactionModel> getTransactionWithItems(int transactionId) async {
    Database db = await database;

    // Fetch the transaction details
    var recordSnapshot = await _transactionStore.record(transactionId).get(db);
    if (recordSnapshot != null) {
      TransactionModel transaction = TransactionModel.fromMap(recordSnapshot);
      transaction.id = transactionId;

      // Fetch the associated items
      var finder =
          Finder(filter: Filter.equals('transactionId', transactionId));
      var itemsSnapshot = await _transactionItemStore.find(db, finder: finder);

      // Convert to list of TransactionItem objects
      transaction.items = [];
      for (var snapshot in itemsSnapshot) {
        var item = TransactionItem.fromMap(snapshot.value);
        item.id = snapshot.key;

        // Fetch the associated Item asynchronously
        if (item.itemId != null) {
          item.item = await getItemById(item.itemId!); // Use await here
        }

        transaction.items.add(item);
      }

      return transaction; // Return the full transaction with its items
    }

    throw Exception('Transaction not found');
  }

}
