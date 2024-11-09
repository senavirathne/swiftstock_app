// item_model.dart

class Item {
  int? id;
  String englishName;
  String displayName;
  String searchingName;
  double buyPricePerUnit;
  double sellPricePerUnit;
  String unit;
  DateTime? expireDate;
  DateTime? addedDate;
  double quantityLeft;
  double initialQuantity;
  int frequency;

  List<double> mostUsedQuantities;

  // New fields for discounts
  double? discountQuantityLevel1;
  double? discountQuantityLevel2;
  double? discountValueLevel1;
  double? discountValueLevel2;
  double? discountPercentLevel1;
  double? discountPercentLevel2;

  Item({
    this.id,
    required this.englishName,
    required this.displayName,
    required this.searchingName,
    required this.buyPricePerUnit,
    required this.sellPricePerUnit,
    required this.unit,
    this.expireDate,
    this.addedDate,
    required this.quantityLeft,
    required this.initialQuantity,
    this.frequency = 0,
    this.mostUsedQuantities = const [],
    this.discountQuantityLevel1,
    this.discountQuantityLevel2,
    this.discountValueLevel1,
    this.discountValueLevel2,
    this.discountPercentLevel1,
    this.discountPercentLevel2,
  });

  Map<String, dynamic> toMap() {
    return {
      'englishName': englishName,
      'displayName': displayName,
      'searchingName': searchingName.replaceAll(' ', ''),
      'buyPricePerUnit': buyPricePerUnit,
      'sellPricePerUnit': sellPricePerUnit,
      'unit': unit,
      'expireDate': expireDate?.toIso8601String(),
      'addedDate': addedDate?.toIso8601String(),
      'quantity': quantityLeft,
      'initialQuantity': initialQuantity,
      'frequency': frequency,
      'discountQuantityLevel1': discountQuantityLevel1,
      'discountQuantityLevel2': discountQuantityLevel2,
      'discountValueLevel1': discountValueLevel1,
      'discountValueLevel2': discountValueLevel2,
      'discountPercentLevel1': discountPercentLevel1,
      'discountPercentLevel2': discountPercentLevel2,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      englishName: map['englishName'] ?? '',
      displayName: map['displayName'] ?? '',
      searchingName: map['searchingName'] ?? '',
      buyPricePerUnit: (map['buyPricePerUnit'] ?? 0).toDouble(),
      sellPricePerUnit: (map['sellPricePerUnit'] ?? 0).toDouble(),
      unit: map['unit'] ?? '',
      expireDate: map['expireDate'] != null && map['expireDate'] != ''
          ? DateTime.parse(map['expireDate'])
          : null,
      addedDate: map['addedDate'] != null && map['addedDate'] != ''
          ? DateTime.parse(map['addedDate'])
          : null,
      quantityLeft: (map['quantity'] ?? 0).toDouble(),
      initialQuantity: (map['initialQuantity'] ?? 0).toDouble(),
      frequency: map['frequency'] ?? 0,
      mostUsedQuantities: [],
      discountQuantityLevel1:
          (map['discountQuantityLevel1'] as num?)?.toDouble(),
      discountQuantityLevel2:
          (map['discountQuantityLevel2'] as num?)?.toDouble(),
      discountValueLevel1: (map['discountValueLevel1'] as num?)?.toDouble(),
      discountValueLevel2: (map['discountValueLevel2'] as num?)?.toDouble(),
      discountPercentLevel1:
          (map['discountPercentLevel1'] as num?)?.toDouble(),
      discountPercentLevel2:
          (map['discountPercentLevel2'] as num?)?.toDouble(),
    );
  }
}
