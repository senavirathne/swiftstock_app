class Item {
  final String name;
  final double pricePerUnit;
  final String unit; // e.g., 'kg', 'unit', etc.
  final int frequency; // Used for sorting by frequency

  Item({
    required this.name,
    required this.pricePerUnit,
    required this.unit,
    this.frequency = 0,
  });
}
