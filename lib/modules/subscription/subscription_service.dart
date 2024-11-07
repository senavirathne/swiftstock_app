// modules/subscription/subscription_service.dart
abstract class SubscriptionService {
  Future<bool> isSubscriptionActive();
  Future<void> validateSubscriptionKeys(List<String> keys);
  // Other methods...
}
