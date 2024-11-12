// main.dart
import 'package:flutter/material.dart';
import 'package:swiftstock_app/services/settings_service.dart';
import 'modules/activity/activity_log_screen.dart';
import 'modules/settings/settings_screen.dart';
import 'modules/subscription/subscription_screen.dart';
import 'modules/subscription/subscription_service.dart';
import 'modules/transaction/add_custom_item_screen.dart';
import 'services/database_service.dart';
import 'services/service_locator.dart';
import 'modules/home/home_screen.dart';
import 'services/settings_service.dart';
import 'utils/feature_flags.dart';
import 'modules/item/item_search_screen.dart';
import 'modules/subscription/subscription_checker.dart';
import 'modules/subscription/subscription_info_screen.dart';
import '/modules/item/expiry_items_screen.dart';
import 'modules/item/edit_items_screen.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  // Fetch the SubscriptionService from the locator
  SubscriptionService subscriptionService = locator<SubscriptionService>();
  await locator<DatabaseService>().init();
  // Check if the subscription is active
  bool isSubscriptionActive = true;// await subscriptionService.isSubscriptionActive();

  runApp(MyApp(isSubscriptionActive: isSubscriptionActive));
}

class MyApp extends StatelessWidget {
  final bool isSubscriptionActive;

  const MyApp({Key? key, required this.isSubscriptionActive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (FeatureFlags.isSubscriptionEnabled) {
      return MaterialApp(
        title: 'Item Transaction App',
        routes: {
          '/subscription':(context) => HomeScreen(),// (context) => SubscriptionScreen(),
          '/home': (context) => HomeScreen(),
          '/item_search': (context) => ItemSearchScreen(),
          '/subscription_info': (context) => SubscriptionInfoScreen(),
          '/edit_items': (context) => EditItemsScreen(),
          '/expiry_items': (context) => ExpiryItemsScreen(),
          '/add_custom_item': (context) => AddCustomItemScreen(),
          '/settings': (context) => SettingsScreen(),
          '/activity_log': (context) => ActivityLogScreen(),
        },
        navigatorObservers: [routeObserver],
        home: SubscriptionChecker(child: HomeScreen()),
      );
    } else {
      return MaterialApp(
        title: 'Item Transaction App',
        routes: {
          '/home': (context) => HomeScreen(),
          '/item_search': (context) => ItemSearchScreen(),
          '/subscription_info': (context) => SubscriptionInfoScreen(),
          '/edit_items': (context) => EditItemsScreen(),
          '/expiry_items': (context) => ExpiryItemsScreen(),
          '/add_custom_item': (context) => AddCustomItemScreen(),
          '/settings': (context) => SettingsScreen(),
          '/activity_log': (context) => ActivityLogScreen(),
          // // Other routes...
        },
        home: HomeScreen(),
      );
    }
  }
}
