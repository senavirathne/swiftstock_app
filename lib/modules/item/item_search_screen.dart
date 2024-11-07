// modules/item/item_search_screen.dart
import 'package:flutter/material.dart';
import 'item_service.dart';
import 'item_model.dart';
import 'package:swiftstock_app/services/service_locator.dart';

class ItemSearchScreen extends StatefulWidget {
  const ItemSearchScreen({super.key});

  @override
  _ItemSearchScreenState createState() => _ItemSearchScreenState();
}

class _ItemSearchScreenState extends State<ItemSearchScreen> {
  List<Item> items = [];
  final ItemService _itemService = ItemService();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    items = await _itemService.getItems();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Items')),
        body: const Center(child: Text('No items available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Items')),
      body: ListView(
        children:
            items.map((item) => ListTile(title: Text(item.name))).toList(),
      ),
    );
  }
}
