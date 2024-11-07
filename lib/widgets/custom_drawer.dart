// widgets/custom_drawer.dart
import 'package:flutter/material.dart';
import 'package:swiftstock_app/utils/feature_flags.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          // Drawer header...
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pushNamed(context, '/home'),
          ),
          if (FeatureFlags.isSubscriptionEnabled)
            ListTile(
              leading: const Icon(Icons.subscriptions),
              title: const Text('Subscription Info'),
              onTap: () => Navigator.pushNamed(context, '/subscription_info'),
            ),
          // Other menu items...
        ],
      ),
    );
  }
}
