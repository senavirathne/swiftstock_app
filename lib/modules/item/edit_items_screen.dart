// lib/modules/item/edit_items_screen.dart

import 'package:flutter/material.dart';
import 'item_model.dart';
import 'item_service.dart';
import 'edit_item_details_screen.dart';
import 'package:swiftstock_app/services/service_locator.dart';

class EditItemsScreen extends StatefulWidget {
  const EditItemsScreen({Key? key}) : super(key: key);

  @override
  _EditItemsScreenState createState() => _EditItemsScreenState();
}

class _EditItemsScreenState extends State<EditItemsScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Item> allItems = [];
  List<Item> displayedItems = [];

  final ItemService? _itemService = locator<ItemService>();

  @override
  void initState() {
    super.initState();
    _loadAllItems();
    _searchController.addListener(() {
      _filterItems(_searchController.text);
    });
  }

  void _loadAllItems() async {
    if (_itemService == null) {
      setState(() {
        allItems = [];
        displayedItems = [];
      });
      return;
    }

    List<Item> items = await _itemService!.getItems();
    setState(() {
      allItems = items;
      displayedItems = items;
    });
  }

  void _filterItems(String query) {
    if (query.isNotEmpty) {
      List<Item> tempList = allItems.where((item) {
        return item.searchingName.toLowerCase().contains(query.toLowerCase());
      }).toList();
      setState(() {
        displayedItems = tempList;
      });
    } else {
      setState(() {
        displayedItems = allItems;
      });
    }
  }

  void _editItem(Item item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditItemDetailsScreen(item: item),
      ),
    );
    // Reload items after editing
    _loadAllItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_itemService == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Edit Items')),
        body: Center(child: Text('Item feature is not available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Items'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by searching name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: displayedItems.isEmpty
                ? Center(child: Text('No items found'))
                : ListView.builder(
                    itemCount: displayedItems.length,
                    itemBuilder: (context, index) {
                      final item = displayedItems[index];
                      return ListTile(
                        title: Text(item.displayName),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editItem(item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
