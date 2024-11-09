// lib/modules/item/edit_item_details_screen.dart

import 'package:flutter/material.dart';
import 'item_model.dart';
import 'item_service.dart';
import 'package:swiftstock_app/services/service_locator.dart';
import 'package:swiftstock_app/modules/activity/activity_service.dart';
import 'package:swiftstock_app/utils/feature_flags.dart';

class EditItemDetailsScreen extends StatefulWidget {
  final Item item;

  const EditItemDetailsScreen({Key? key, required this.item}) : super(key: key);

  @override
  _EditItemDetailsScreenState createState() => _EditItemDetailsScreenState();
}

class _EditItemDetailsScreenState extends State<EditItemDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _englishName;
  late String _displayName;
  late String _searchingName;
  late double _buyPricePerUnit;
  late double _sellPricePerUnit;
  late String _unit;
  late double _initialQuantity;
  late double _quantity;
  late DateTime? _expireDate;

  final ItemService? _itemService = locator<ItemService>();
  final ActivityService? _activityService = locator<ActivityService>();

  @override
  void initState() {
    super.initState();
    _englishName = widget.item.englishName;
    _displayName = widget.item.displayName;
    _searchingName = widget.item.searchingName;
    _buyPricePerUnit = widget.item.buyPricePerUnit;
    _sellPricePerUnit = widget.item.sellPricePerUnit;
    _unit = widget.item.unit;
    _quantity = widget.item.quantityLeft;
    _expireDate = widget.item.expireDate;
    _initialQuantity = widget.item.initialQuantity;
  }

  void _confirmDeleteItem() async {
    if (_itemService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item service is not available.')),
      );
      return;
    }

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text(
            'Are you sure you want to delete this item? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _itemService!.deleteItem(widget.item.id!);
      // Log the activity
      if (FeatureFlags.isActivityEnabled && _activityService != null) {
        await _activityService!.logActivity(
          'Deleted item: ${widget.item.displayName}',
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item deleted successfully')),
      );
      Navigator.pop(context);
    }
  }

  void _saveItem() async {
    if (_itemService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item service is not available.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Item updatedItem = Item(
        id: widget.item.id,
        englishName: _englishName,
        displayName: _displayName,
        searchingName: _searchingName,
        buyPricePerUnit: _buyPricePerUnit,
        sellPricePerUnit: _sellPricePerUnit,
        unit: _unit,
        expireDate: _expireDate,
        addedDate: widget.item.addedDate,
        initialQuantity: _initialQuantity,
        quantityLeft: _quantity,
        frequency: widget.item.frequency,
      );

      await _itemService!.updateItem(updatedItem);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item updated successfully')),
      );

      // Log the activity
      if (FeatureFlags.isActivityEnabled && _activityService != null) {
        await _activityService!.logActivity(
          'Updated item: ${updatedItem.displayName}',
        );
      }

      Navigator.pop(context);
    }
  }

  Future<void> _selectExpireDate() async {
    DateTime initialDate = _expireDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _expireDate) {
      setState(() {
        _expireDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_itemService == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Edit Item Details')),
        body: Center(child: Text('Item feature is not available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Item Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _confirmDeleteItem,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: _englishName,
              decoration: InputDecoration(labelText: 'English Name'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter English name' : null,
              onSaved: (value) => _englishName = value!,
            ),
            TextFormField(
              initialValue: _displayName,
              decoration: InputDecoration(labelText: 'Display Name'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter display name' : null,
              onSaved: (value) => _displayName = value!,
            ),
            TextFormField(
              initialValue: _searchingName,
              decoration: InputDecoration(labelText: 'Searching Name'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter searching name' : null,
              onSaved: (value) => _searchingName = value!,
            ),
            TextFormField(
              initialValue: _buyPricePerUnit.toString(),
              decoration: InputDecoration(labelText: 'Buy Price per Unit'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) => (value == null ||
                      double.tryParse(value) == null ||
                      double.parse(value) < 0)
                  ? 'Please enter valid buy price'
                  : null,
              onSaved: (value) => _buyPricePerUnit = double.parse(value!),
            ),
            TextFormField(
              initialValue: _sellPricePerUnit.toString(),
              decoration: InputDecoration(labelText: 'Sell Price per Unit'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) => (value == null ||
                      double.tryParse(value) == null ||
                      double.parse(value) <= 0)
                  ? 'Please enter valid sell price'
                  : null,
              onSaved: (value) => _sellPricePerUnit = double.parse(value!),
            ),
            TextFormField(
              initialValue: _unit,
              decoration: InputDecoration(labelText: 'Unit (e.g., kg, unit)'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter unit' : null,
              onSaved: (value) => _unit = value!,
            ),
            TextFormField(
              initialValue: _quantity.toString(),
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) => (value == null ||
                      double.tryParse(value) == null ||
                      double.parse(value) < 0)
                  ? 'Please enter valid quantity'
                  : null,
              onSaved: (value) => _quantity = double.parse(value!),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text(
                  'Expire Date: ${_expireDate != null ? _expireDate!.toLocal().toString().split(' ')[0] : 'Not set'}'),
              trailing: Icon(Icons.calendar_today),
              onTap: _selectExpireDate,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveItem,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

