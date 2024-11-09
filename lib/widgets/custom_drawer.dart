// widgets/custom_drawer.dart
import 'package:flutter/material.dart';
import 'package:swiftstock_app/utils/feature_flags.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Item Transaction App',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          if (FeatureFlags.isSubscriptionEnabled)
            ListTile(
              leading: Icon(Icons.subscriptions),
              title: Text('Subscription Info'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/subscription_info');
              },
            ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: Icon(Icons.warning),
            title: Text('Items About to Expire'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/expiry_items');
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Activity Log'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/activity_log');
            },
          ),
        ],
      ),
    );
  }
}
