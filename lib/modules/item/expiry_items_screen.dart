// lib/modules/item/expiry_items_screen.dart

import 'package:flutter/material.dart';
import 'item_model.dart';
import 'item_service.dart';
import 'package:swiftstock_app/services/service_locator.dart';

class ExpiryItemsScreen extends StatefulWidget {
  const ExpiryItemsScreen({Key? key}) : super(key: key);

  @override
  _ExpiryItemsScreenState createState() => _ExpiryItemsScreenState();
}

class _ExpiryItemsScreenState extends State<ExpiryItemsScreen> {
  List<Item> allExpiringItems = [];
  String _selectedDuration = '1 Week';
  List<String> durations = ['1 Week', '2 Weeks', '1 Month', '2 Months', 'All'];

  final ItemService? _itemService = locator<ItemService>();

  @override
  void initState() {
    super.initState();
    _loadExpiringItems();
  }

  void _loadExpiringItems() async {
    if (_itemService == null) {
      setState(() {
        allExpiringItems = [];
      });
      return;
    }

    List<Item> items = await _itemService!.getItems();
    DateTime now = DateTime.now();

    List<Item> tempExpiringItems = [];

    for (var item in items) {
      if (item.expireDate != null) {
        final difference = item.expireDate!.difference(now).inDays;
        if (difference >= 0) {
          tempExpiringItems.add(item);
        }
      } else if (_selectedDuration == 'All') {
        tempExpiringItems.add(item);
      }
    }

    // Sort items by expiry date
    tempExpiringItems.sort((a, b) => a.expireDate!.compareTo(b.expireDate!));

    setState(() {
      allExpiringItems = tempExpiringItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_itemService == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Items About to Expire')),
        body: Center(child: Text('Item feature is not available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Items About to Expire'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedDuration,
              items: durations.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child:
                      Text(value == 'All' ? 'All Items' : 'Within $value'),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedDuration = newValue!;
                  _loadExpiringItems();
                });
              },
            ),
          ),
          Expanded(
            child: _buildItemList(),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList() {
    List<Item> itemsToDisplay = [];
    DateTime now = DateTime.now();
    int maxDifference = 0;

    switch (_selectedDuration) {
      case '1 Week':
        maxDifference = 7;
        break;
      case '2 Weeks':
        maxDifference = 14;
        break;
      case '1 Month':
        maxDifference = 30;
        break;
      case '2 Months':
        maxDifference = 60;
        break;
      case 'All':
        maxDifference = -1; // Show all
        break;
      default:
        maxDifference = -1; // Show all
        break;
    }

    if (maxDifference == -1) {
      itemsToDisplay = allExpiringItems;
    } else {
      itemsToDisplay = allExpiringItems.where((item) {
        final difference = item.expireDate!.difference(now).inDays;
        return difference >= 0 && difference <= maxDifference;
      }).toList();
    }

    if (itemsToDisplay.isEmpty) {
      return Center(
        child: Text('No items expiring within $_selectedDuration.'),
      );
    }

    return ListView.builder(
      itemCount: itemsToDisplay.length,
      itemBuilder: (context, index) {
        final item = itemsToDisplay[index];
        return ListTile(
          title: Text(item.displayName),
          subtitle: Text(
            'Expires on: ${item.expireDate!.toLocal().toString().split(' ')[0]}',
          ),
        );
      },
    );
  }
}
