// modules/subscription/subscription_screen.dart

import 'package:flutter/material.dart';
import 'subscription_service.dart';
import 'package:swiftstock_app/services/service_locator.dart';
import 'package:swiftstock_app/modules/home/home_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _subscriptionKeyController = TextEditingController();
  bool _isLoading = false;
  final SubscriptionService _subscriptionService =
      locator<SubscriptionService>();

  void _validateSubscriptionKeys() async {
    setState(() {
      _isLoading = true;
    });

    String inputText = _subscriptionKeyController.text.trim();
    List<String> keys = inputText.split(',').map((s) => s.trim()).toList();

    await _subscriptionService.validateSubscriptionKeys(keys);

    setState(() {
      _isLoading = false;
    });

    bool isValid = await _subscriptionService.isSubscriptionActive();

    if (isValid) {
      // Subscription activated, navigate to HomeScreen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      // Invalid subscription key(s)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'One or more subscription keys are invalid or already used')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Subscription Keys'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _subscriptionKeyController,
              decoration: InputDecoration(
                labelText: 'Subscription Keys (comma-separated)',
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _validateSubscriptionKeys,
                    child: Text('Activate'),
                  ),
          ],
        ),
      ),
    );
  }
}
