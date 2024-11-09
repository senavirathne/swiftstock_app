// modules/subscription/null_subscription_service.dart

import 'subscription_service.dart';

class NullSubscriptionService implements SubscriptionService {
  @override
  Future<bool> isSubscriptionActive() async => true;

  @override
  Future<void> validateSubscriptionKeys(List<String> keys) async {
    // Do nothing
  }

  @override
  Future<DateTime?> getOverallExpiryDate() async {
    return DateTime.now().add(Duration(days: 3650)); // Far future date
  }

  @override
  Future<void> updateExpiryDate(int additionalMonths) async {
    // Do nothing
  }

  @override
  Future<String?> getExpiryDate() async {
    return DateTime.now().add(Duration(days: 3650)).toIso8601String();
  }
}
