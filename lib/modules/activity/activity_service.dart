// modules/activity/activity_service.dart

import 'package:flutter/foundation.dart';
import 'package:swiftstock_app/services/service_locator.dart';
import 'package:swiftstock_app/services/database_service.dart';
import 'activity_model.dart';

class ActivityService {
  final DatabaseService? _dbService = locator<DatabaseService>();

  Future<List<Activity>> getAllActivities() async {
    if (_dbService == null) {
      // Handle absence of database service
      debugPrint('DatabaseService is not available. Returning empty activity list.');
      return [];
    }
    return await _dbService!.getAllActivities();
  }

  Future<void> insertActivity(Activity activity) async {
    if (_dbService == null) {
      // Handle absence of database service
      debugPrint('DatabaseService is not available. Cannot insert activity.');
      return;
    }
    await _dbService!.insertActivity(activity);
  }

  logActivity(String s) {}
}
