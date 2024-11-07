import 'package:swiftstock_app/modules/item/item_model.dart';

class TransactionItem {
  final Item item;
  double quantity;
  double adjustedPrice;

  TransactionItem({
    required this.item,
    required this.quantity,
    required this.adjustedPrice,
  });
}
