// modules/transaction/transaction_model.dart
import 'package:swiftstock_app/modules/item/item_model.dart';
class Transaction {
  int? id;
  List<TransactionItem> items;
  double totalAmount;
  DateTime dateTime;

  Transaction({
    this.id,
    required this.items,
    required this.totalAmount,
    required this.dateTime,
  });
}

class TransactionItem {
  int? id;
  Item item;
  double quantity;
  double price;

  TransactionItem({
    this.id,
    required this.item,
    required this.quantity,
    required this.price,
  });
}
