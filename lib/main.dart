// main.dart
import 'package:flutter/material.dart';
import 'services/service_locator.dart';
import 'modules/home/home_screen.dart';
import 'utils/feature_flags.dart';
import 'modules/item/item_search_screen.dart';
import 'modules/subscription/subscription_checker.dart';
import 'modules/subscription/subscription_info_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modular App',
      routes: {
        '/home': (context) => HomeScreen(),
        '/item_search': (context) => ItemSearchScreen(),
        '/subscription_info': (context) => SubscriptionInfoScreen(),
        // Other routes...
      },
      home: FeatureFlags.isSubscriptionEnabled
          ? SubscriptionChecker(child: HomeScreen())
          : HomeScreen(),
    );
  }
}
