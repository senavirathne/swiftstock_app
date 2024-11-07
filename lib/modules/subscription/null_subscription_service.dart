// modules/subscription/null_subscription_service.dart
import 'subscription_service.dart';

class NullSubscriptionService implements SubscriptionService {
  @override
  Future<bool> isSubscriptionActive() async => true;

  @override
  Future<void> validateSubscriptionKeys(List<String> keys) async {
    // Do nothing
  }
}
