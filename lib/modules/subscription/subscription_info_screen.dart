// modules/subscription/subscription_info_screen.dart

import 'package:flutter/material.dart';
import 'subscription_service.dart';
import 'package:swiftstock_app/services/service_locator.dart';

class SubscriptionInfoScreen extends StatefulWidget {
  const SubscriptionInfoScreen({Key? key}) : super(key: key);

  @override
  _SubscriptionInfoScreenState createState() => _SubscriptionInfoScreenState();
}

class _SubscriptionInfoScreenState extends State<SubscriptionInfoScreen> {
  String remainingDays = '';
  String subscribedDate = '';
  TextEditingController _subscriptionKeysController = TextEditingController();
  bool _isLoading = false;
  final SubscriptionService _subscriptionService =
      locator<SubscriptionService>();

  @override
  void initState() {
    super.initState();
    _loadSubscriptionInfo();
  }

  @override
  void dispose() {
    _subscriptionKeysController.dispose();
    super.dispose();
  }

  // Load subscription keys and overall expiry date
  void _loadSubscriptionInfo() async {
    setState(() {
      _isLoading = true;
    });

    // Get the overall expiry date
    DateTime? overallExpiryDate =
        await _subscriptionService.getOverallExpiryDate();

    if (overallExpiryDate != null) {
      DateTime now = DateTime.now();
      int daysLeft = overallExpiryDate.difference(now).inDays;
      daysLeft = daysLeft < 0 ? 0 : daysLeft;

      setState(() {
        remainingDays = daysLeft.toString();
        subscribedDate = overallExpiryDate.toLocal().toString().split(' ')[0];
      });
    } else {
      setState(() {
        remainingDays = '0';
        subscribedDate = 'N/A';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Activate subscription keys entered by the user
  void _activateSubscriptionKeys() async {
    setState(() {
      _isLoading = true;
    });

    String inputText = _subscriptionKeysController.text.trim();
    List<String> keys = inputText.split(',').map((s) => s.trim()).toList();

    // Validate and activate the keys
    await _subscriptionService.validateSubscriptionKeys(keys);

    setState(() {
      _isLoading = false;
    });

    bool isValid = await _subscriptionService.isSubscriptionActive();

    if (isValid) {
      // Reload the subscription info to reflect the new keys
      _loadSubscriptionInfo();

      // Clear the input field
      _subscriptionKeysController.clear();

      // Inform the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Subscription keys activated successfully')),
      );
    } else {
      // Inform the user about invalid or already used keys
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'One or more subscription keys are invalid or already used')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display Remaining Days and Subscribed Until
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Remaining Days: $remainingDays',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Subscribed Until: $subscribedDate',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Input Field to Enter Subscription Keys
            TextField(
              controller: _subscriptionKeysController,
              decoration: const InputDecoration(
                labelText: 'Enter Subscription Keys (comma-separated)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // Activate Button
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _activateSubscriptionKeys,
                    child: const Text('Activate Subscription Keys'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
