// modules/transaction/transaction_service.dart

import 'package:swiftstock_app/services/service_locator.dart';
import 'package:swiftstock_app/services/database_service.dart';
import 'transaction_model.dart';
import 'package:swiftstock_app/modules/item/item_model.dart';

class TransactionService {
  final DatabaseService? _databaseService = locator<DatabaseService>();

  Future<int> insertTransaction(TransactionModel transaction) async {
    if (_databaseService == null) {
      // Handle absence of database service
      return -1;
    }

    try {
      // Insert the transaction into the database
      int transactionId =
          await _databaseService!.insertTransaction(transaction);
      return transactionId;
    } catch (e) {
      // Handle exceptions
      print('Error inserting transaction: $e');
      return -1;
    }
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    if (_databaseService == null) {
      return [];
    }

    try {
      return await _databaseService!.getAllTransactions();
    } catch (e) {
      print('Error retrieving transactions: $e');
      return [];
    }
  }

  Future<void> updateItemFrequency(int i) async {
    try {
      await _databaseService!.updateItemFrequency(i);
    } catch (e) {
      print('Error updateItemFrequency: $e');
      
    }
  }

}
