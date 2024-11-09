// modules/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:swiftstock_app/widgets/custom_drawer.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: Text('Item Transaction App'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Start Transaction'),
          onPressed: () {
            Navigator.pushNamed(context, '/item_search');
          },
        ),
      ),
    );
  }
}
