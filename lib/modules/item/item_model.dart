// modules/item/item_model.dart
class Item {
  int? id;
  String name;
  String unit;
  double pricePerUnit;
  // Other fields...

  Item({this.id, required this.name,required this.unit, required this.pricePerUnit});

  // toMap and fromMap methods...
}
