// modules/subscription/subscription_checker.dart
import 'package:flutter/material.dart';
import 'package:swiftstock_app/services/service_locator.dart';
import 'subscription_service.dart';
import 'subscription_screen.dart';

class SubscriptionChecker extends StatelessWidget {
  final Widget child;

  const SubscriptionChecker({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final subscriptionService = locator<SubscriptionService>();

    return FutureBuilder<bool>(
      future: subscriptionService.isSubscriptionActive(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while checking the subscription
          return const Scaffold(
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
