// services/settings_service.dart

import 'package:flutter/material.dart';
import 'package:swiftstock_app/services/service_locator.dart';
import 'database_service.dart';

abstract class SettingsService {
  static late final DatabaseService instance;
  Future<void> saveSetting(String key, dynamic value);
  Future<dynamic> getSetting(String key);
  int getNumberOfModItems();
  void setNumberOfModItems(int number);
}

class RealSettingsService implements SettingsService {
  final DatabaseService? _databaseService = locator<DatabaseService>();

  int _numberOfModItems = 5;

  @override
  Future<void> saveSetting(String key, dynamic value) async {
    await _databaseService?.saveSetting(key, value);
  }

  @override
  Future<dynamic> getSetting(String key) async {
    return await _databaseService?.getSetting(key);
  }

  @override
  int getNumberOfModItems() {
    return _numberOfModItems;
  }

  @override
  void setNumberOfModItems(int number) {
    _numberOfModItems = number;
  }
}

class NullSettingsService implements SettingsService {
  @override
  int getNumberOfModItems() {
    // TODO: implement getNumberOfModItems
    throw UnimplementedError();
  }

  @override
  Future getSetting(String key) {
    // TODO: implement getSetting
    throw UnimplementedError();
  }

  @override
  Future<void> saveSetting(String key, value) {
    // TODO: implement saveSetting
    throw UnimplementedError();
  }

  @override
  void setNumberOfModItems(int number) {
    // TODO: implement setNumberOfModItems
  }

}