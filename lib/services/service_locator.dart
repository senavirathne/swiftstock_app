// services/service_locator.dart
import 'package:get_it/get_it.dart';
import 'database_service.dart';
import 'null_database_service.dart';
import 'real_database_service.dart';
import 'package:swiftstock_app/utils/feature_flags.dart';
import 'package:swiftstock_app/modules/subscription/subscription_service.dart';
import 'package:swiftstock_app/modules/subscription/real_subscription_service.dart';
import 'package:swiftstock_app/modules/subscription/null_subscription_service.dart';
final GetIt locator = GetIt.instance;

void setupLocator() {
  if (FeatureFlags.isDatabaseEnabled) {
    locator.registerLazySingleton<DatabaseService>(() => RealDatabaseService());
  } else {
    locator.registerLazySingleton<DatabaseService>(() => NullDatabaseService());
  }

  if (FeatureFlags.isSubscriptionEnabled) {
    locator.registerLazySingleton<SubscriptionService>(
        () => RealSubscriptionService());
  } else {
    locator.registerLazySingleton<SubscriptionService>(
        () => NullSubscriptionService());
  }

  // Similarly, register other services
}
