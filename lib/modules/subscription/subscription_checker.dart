// modules/subscription/subscription_checker.dart

import 'package:flutter/material.dart';
import 'subscription_service.dart';
import 'package:swiftstock_app/services/service_locator.dart';
import 'subscription_screen.dart';

class SubscriptionChecker extends StatelessWidget {
  final Widget child;

  SubscriptionChecker({required this.child});

  @override
  Widget build(BuildContext context) {
    final SubscriptionService _subscriptionService = locator<SubscriptionService>();

    return FutureBuilder<bool>(
      future: _subscriptionService.isSubscriptionActive(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while checking the subscription
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData && snapshot.data == true) {
          // Subscription is active, show the child widget
          return child;
        } else {
          // Subscription is inactive, navigate to subscription screen
          return SubscriptionScreen();
        }
      },
    );
  }
}
