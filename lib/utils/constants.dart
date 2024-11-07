import 'package:swiftstock_app/modules/item/item_model.dart';

class DiscountUtil {
  static double applyQuantityDiscount(Item item, double quantity) {
    double adjustedPrice = item.pricePerUnit;
    if (item.unit == 'kg' && quantity > 20) {
      adjustedPrice *= 0.9; // 10% discount
    }
    return adjustedPrice;
  }
}
