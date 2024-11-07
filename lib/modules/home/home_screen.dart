// modules/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:swiftstock_app/widgets/custom_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Build your home screen
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      drawer: CustomDrawer(),
      body: Center(
        child: ElevatedButton(
          child: const Text('Start Transaction'),
          onPressed: () {
            Navigator.pushNamed(context, '/item_search');
          },
        ),
      ),
    );
  }
}
