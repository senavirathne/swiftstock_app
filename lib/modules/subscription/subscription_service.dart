// modules/subscription/subscription_service.dart

abstract class SubscriptionService {
  Future<bool> isSubscriptionActive();
  Future<void> validateSubscriptionKeys(List<String> keys);
  Future<DateTime?> getOverallExpiryDate();
  Future<void> updateExpiryDate(int additionalMonths);
  Future<String?> getExpiryDate();
}
