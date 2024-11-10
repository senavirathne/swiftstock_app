// services/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:swiftstock_app/modules/activity/DefaultActivityService.dart';
import 'package:swiftstock_app/modules/activity/activity_service.dart';
import 'package:swiftstock_app/modules/item/item_service.dart';
import 'database_service.dart';
import 'import_service.dart';
import 'null_database_service.dart';
import 'real_database_service.dart';
import 'package:swiftstock_app/utils/feature_flags.dart';
import 'package:swiftstock_app/modules/subscription/subscription_service.dart';
import 'package:swiftstock_app/modules/subscription/real_subscription_service.dart';
import 'package:swiftstock_app/modules/subscription/null_subscription_service.dart';

import 'settings_service.dart';
final GetIt locator = GetIt.instance;
// RealDatabaseService()
void setupLocator() {
  locator.registerLazySingleton<DatabaseService>(
    () => FeatureFlags.isDatabaseEnabled ? RealDatabaseService() :NullDatabaseService());
  locator.registerLazySingleton<SubscriptionService>(
    () => FeatureFlags.isSubscriptionEnabled ? RealSubscriptionService() : NullSubscriptionService());
  locator.registerLazySingleton<SettingsService>(
    () => FeatureFlags.isSubscriptionEnabled ? RealSettingsService() : NullSettingsService());
  locator.registerLazySingleton<ImportService>(
    () => RealImportService());
  locator.registerLazySingleton<ItemService>(
    () => ItemService());
  locator.registerLazySingleton<ActivityService>(
    () => FeatureFlags.isActivityEnabled ? ActivityService(): DefaultActivityService());
  
  // Similarly, register other services
}
