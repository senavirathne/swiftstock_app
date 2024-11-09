// modules/transaction/transaction_model.dart

import 'package:swiftstock_app/modules/item/item_model.dart';


class TransactionModel {
  int? id;
  List<TransactionItem> items;
  double totalAmount;
  double amountPaid;
  DateTime dateTime;

  TransactionModel({
    this.id,
    required this.items,
    required this.totalAmount,
    required this.amountPaid,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalAmount': totalAmount,
      'amountPaid': amountPaid,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      items: [],
      totalAmount: map['totalAmount'],
      amountPaid: map['amountPaid'],
      dateTime: DateTime.parse(map['dateTime']),
    );
  }
}


class TransactionItem {
  int? id;
  int? transactionId;
  int? itemId;
  Item? item;
  String? customItemName;
  String? unit;
  double quantity;
  double adjustedPrice;
  double? discountAmount;
  double? discountPercent;
  bool isDiscountPercent;

  TransactionItem({
    this.id,
    this.transactionId,
    this.itemId,
    this.item,
    this.customItemName,
    this.unit,
    required this.quantity,
    required this.adjustedPrice,
    this.discountAmount,
    this.discountPercent,
    this.isDiscountPercent = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'itemId': item?.id ?? itemId,
      'customItemName': customItemName,
      'unit': unit,
      'quantity': quantity,
      'adjustedPrice': adjustedPrice,
      'discountAmount': discountAmount,
      'discountPercent': discountPercent,
      'isDiscountPercent': isDiscountPercent ? 1 : 0,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'],
      transactionId: map['transactionId'],
      itemId: map['itemId'],
      item: null,
      customItemName: map['customItemName'],
      unit: map['unit'],
      quantity: map['quantity'],
      adjustedPrice: map['adjustedPrice'],
      discountAmount: map['discountAmount'],
      discountPercent: map['discountPercent'],
      isDiscountPercent: map['isDiscountPercent'] == 1,
    );
  }
}
