// lib/modules/subscription/subscription_screen.dart

import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscription Required'),
      ),
      body: Center(
        child: Text('Please activate your subscription.'),
      ),
    );
  }
}
