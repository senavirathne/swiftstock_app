import 'transaction_model.dart';

class Transaction {
  final List<TransactionItem> items;
  final double totalAmount;
  final double amountPaid;
  final DateTime dateTime;

  Transaction({
    required this.items,
    required this.totalAmount,
    required this.amountPaid,
    required this.dateTime,
  });
}
