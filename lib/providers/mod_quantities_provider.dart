// lib/providers/mod_quantities_provider.dart
// Provides the number of most used quantities to display.

import 'package:flutter/material.dart';

class ModQuantitiesProvider extends ChangeNotifier {
  int _numberOfModItems = 5; // Default to 5

  int get numberOfModItems => _numberOfModItems;

  void setNumberOfModItems(int number) {
    _numberOfModItems = number;
    notifyListeners();
  }
}
