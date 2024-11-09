// add_item_screen.dart

import 'package:flutter/material.dart';
import 'package:swiftstock_app/services/database_service.dart';
import 'package:swiftstock_app/modules/item/item_model.dart';
import 'package:swiftstock_app/modules/activity/activity_model.dart';
import 'package:swiftstock_app/services/service_locator.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({Key? key}) : super(key: key);

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();

  String _englishName = '';
  String _displayName = '';
  String _searchingName = '';
  double _buyPricePerUnit = 0.0;
  double _sellPricePerUnit = 0.0;
  String _unit = '';
  double _initialQuantity = 0.0;
  double _quantity = 1.0;

  // Variables for day, month, year
  int _expireDay = DateTime.now().day;
  int _expireMonth = DateTime.now().month;
  int _expireYear = DateTime.now().year;

  // Discount parameters
  double? _discountQuantityLevel1;
  double? _discountQuantityLevel2;
  double? _discountValueLevel1;
  double? _discountValueLevel2;
  double? _discountPercentLevel1;
  double? _discountPercentLevel2;

  // Define FocusNodes for each input field to manage focus
  final FocusNode _englishNameFocusNode = FocusNode();
  final FocusNode _displayNameFocusNode = FocusNode();
  final FocusNode _searchingNameFocusNode = FocusNode();
  final FocusNode _buyPricePerUnitFocusNode = FocusNode();
  final FocusNode _sellPricePerUnitFocusNode = FocusNode();
  final FocusNode _unitFocusNode = FocusNode();
  final FocusNode _quantityFocusNode = FocusNode();
  // FocusNodes for date components
  final FocusNode _expireDayFocusNode = FocusNode();
  final FocusNode _expireMonthFocusNode = FocusNode();
  final FocusNode _expireYearFocusNode = FocusNode();
  final FocusNode _addNextButtonFocusNode = FocusNode();

  // FocusNodes for discount fields (optional)
  final FocusNode _discountQuantityLevel2FocusNode = FocusNode();
  final FocusNode _discountValueLevel1FocusNode = FocusNode();
  final FocusNode _discountValueLevel2FocusNode = FocusNode();
  final FocusNode _discountPercentLevel1FocusNode = FocusNode();
  final FocusNode _discountPercentLevel2FocusNode = FocusNode();

  @override
  void dispose() {
    // Dispose of the FocusNodes when the State is disposed
    _englishNameFocusNode.dispose();
    _displayNameFocusNode.dispose();
    _searchingNameFocusNode.dispose();
    _buyPricePerUnitFocusNode.dispose();
    _sellPricePerUnitFocusNode.dispose();
    _unitFocusNode.dispose();
    _quantityFocusNode.dispose();
    _expireDayFocusNode.dispose();
    _expireMonthFocusNode.dispose();
    _expireYearFocusNode.dispose();
    _addNextButtonFocusNode.dispose();
    // Dispose discount FocusNodes
    _discountQuantityLevel2FocusNode.dispose();
    _discountValueLevel1FocusNode.dispose();
    _discountValueLevel2FocusNode.dispose();
    _discountPercentLevel1FocusNode.dispose();
    _discountPercentLevel2FocusNode.dispose();
    super.dispose();
  }

  void _addNextItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      DateTime? _expireDate;
      try {
        _expireDate = DateTime(_expireYear, _expireMonth, _expireDay);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid expiry date')));
        return;
      }

      Item newItem = Item(
        englishName: _englishName,
        displayName: _displayName,
        searchingName: _searchingName,
        buyPricePerUnit: _buyPricePerUnit,
        sellPricePerUnit: _sellPricePerUnit,
        unit: _unit,
        expireDate: _expireDate,
        addedDate: DateTime.now(),
        initialQuantity: _quantity,
        quantityLeft: _quantity,
        // Set discount parameters
        discountQuantityLevel1: _discountQuantityLevel1,
        discountQuantityLevel2: _discountQuantityLevel2,
        discountValueLevel1: _discountValueLevel1,
        discountValueLevel2: _discountValueLevel2,
        discountPercentLevel1: _discountPercentLevel1,
        discountPercentLevel2: _discountPercentLevel2,
      );

      int itemId = await locator<DatabaseService>().insertItem(newItem);
      newItem.id = itemId;

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item $_displayName added successfully')));
      // Log the activity
      await locator<DatabaseService>().insertActivity(
        Activity(
          description: 'Added new item: ${newItem.displayName}',
          dateTime: DateTime.now(),
        ),
      );

      // Reset the form for the next item
      _formKey.currentState!.reset();
      setState(() {
        _englishName = '';
        _displayName = '';
        _searchingName = '';
        _buyPricePerUnit = 0.0;
        _sellPricePerUnit = 0.0;
        _unit = '';
        _quantity = 0.0;
        _expireDay = DateTime.now().day;
        _expireMonth = DateTime.now().month;
        _expireYear = DateTime.now().year;
        _discountQuantityLevel1 = null;
        _discountQuantityLevel2 = null;
        _discountValueLevel1 = null;
        _discountValueLevel2 = null;
        _discountPercentLevel1 = null;
        _discountPercentLevel2 = null;
        FocusScope.of(context).requestFocus(_englishNameFocusNode);
      });
    }
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      DateTime? _expireDate;
      try {
        _expireDate = DateTime(_expireYear, _expireMonth, _expireDay);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid expiry date')));
        return;
      }

      Item newItem = Item(
        englishName: _englishName,
        displayName: _displayName,
        searchingName: _searchingName,
        buyPricePerUnit: _buyPricePerUnit,
        sellPricePerUnit: _sellPricePerUnit,
        unit: _unit,
        expireDate: _expireDate,
        addedDate: DateTime.now(),
        initialQuantity: _quantity,
        quantityLeft: _quantity,
        // Set discount parameters
        discountQuantityLevel1: _discountQuantityLevel1,
        discountQuantityLevel2: _discountQuantityLevel2,
        discountValueLevel1: _discountValueLevel1,
        discountValueLevel2: _discountValueLevel2,
        discountPercentLevel1: _discountPercentLevel1,
        discountPercentLevel2: _discountPercentLevel2,
      );

      int itemId = await locator<DatabaseService>().insertItem(newItem);
      newItem.id = itemId;

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item $_displayName added successfully')));

      // Log the activity
      await locator<DatabaseService>().insertActivity(
        Activity(
          description: 'Added new item: ${newItem.displayName}',
          dateTime: DateTime.now(),
        ),
      );

      // Reset the form for the next item
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add New Item'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                focusNode: _englishNameFocusNode,
                decoration: const InputDecoration(labelText: 'English Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter English name' : null,
                onSaved: (value) => _englishName = value!,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_displayNameFocusNode);
                },
              ),
              TextFormField(
                focusNode: _displayNameFocusNode,
                decoration: const InputDecoration(labelText: 'Display Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter display name' : null,
                onSaved: (value) => _displayName = value!,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_searchingNameFocusNode);
                },
              ),
              TextFormField(
                focusNode: _searchingNameFocusNode,
                decoration: const InputDecoration(labelText: 'Searching Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter searching name' : null,
                onSaved: (value) => _searchingName = value!,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_buyPricePerUnitFocusNode);
                },
              ),
              TextFormField(
                focusNode: _buyPricePerUnitFocusNode,
                decoration:
                    const InputDecoration(labelText: 'Buy Price per Unit'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => (value == null ||
                        double.tryParse(value) == null ||
                        double.parse(value) <= 0)
                    ? 'Please enter valid buy price'
                    : null,
                onSaved: (value) => _buyPricePerUnit = double.parse(value!),
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_sellPricePerUnitFocusNode);
                },
              ),
              TextFormField(
                focusNode: _sellPricePerUnitFocusNode,
                decoration:
                    const InputDecoration(labelText: 'Sell Price per Unit'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => (value == null ||
                        double.tryParse(value) == null ||
                        double.parse(value) <= 0)
                    ? 'Please enter valid sell price'
                    : null,
                onSaved: (value) => _sellPricePerUnit = double.parse(value!),
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_unitFocusNode);
                },
              ),
              TextFormField(
                focusNode: _unitFocusNode,
                decoration:
                    const InputDecoration(labelText: 'Unit (e.g., kg, unit)'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter unit' : null,
                onSaved: (value) => _unit = value!,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_quantityFocusNode);
                },
              ),
              TextFormField(
                focusNode: _quantityFocusNode,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                initialValue: '1', // Default quantity is 1
                validator: (value) => (value == null ||
                        double.tryParse(value) == null ||
                        double.parse(value) < 0)
                    ? 'Please enter valid quantity'
                    : null,
                onSaved: (value) => _quantity = double.parse(value!),
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_expireDayFocusNode);
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Expiry Date',
                style: TextStyle(fontSize: 16),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      focusNode: _expireDayFocusNode,
                      decoration: const InputDecoration(labelText: 'Day'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: false),
                      initialValue: _expireDay.toString(),
                      validator: (value) {
                        int? day = int.tryParse(value ?? '');
                        if (day == null || day < 1 || day > 31) {
                          return 'Invalid day';
                        }
                        return null;
                      },
                      onSaved: (value) => _expireDay = int.parse(value!),
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_expireMonthFocusNode);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      focusNode: _expireMonthFocusNode,
                      decoration: const InputDecoration(labelText: 'Month'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: false),
                      initialValue: _expireMonth.toString(),
                      validator: (value) {
                        int? month = int.tryParse(value ?? '');
                        if (month == null || month < 1 || month > 12) {
                          return 'Invalid month';
                        }
                        return null;
                      },
                      onSaved: (value) => _expireMonth = int.parse(value!),
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_expireYearFocusNode);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      focusNode: _expireYearFocusNode,
                      decoration: const InputDecoration(labelText: 'Year'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: false),
                      initialValue: _expireYear.toString(),
                      validator: (value) {
                        int? year = int.tryParse(value ?? '');
                        if (year == null || year < 2000 || year > 2100) {
                          return 'Invalid year';
                        }
                        return null;
                      },
                      onSaved: (value) => _expireYear = int.parse(value!),
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_addNextButtonFocusNode);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Discount Parameters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Table(
                border: TableBorder.all(),
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Discount Quantity',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Discount Value',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Discount Percent',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Level 1 Row
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration:
                              const InputDecoration(hintText: 'Qty Level 1'),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onSaved: (value) => _discountQuantityLevel1 =
                              value != null && value.isNotEmpty
                                  ? double.parse(value)
                                  : null,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_discountQuantityLevel2FocusNode);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          focusNode: _discountValueLevel1FocusNode,
                          decoration:
                              const InputDecoration(hintText: 'Value Level 1'),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onSaved: (value) => _discountValueLevel1 =
                              value != null && value.isNotEmpty
                                  ? double.parse(value)
                                  : null,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_discountValueLevel2FocusNode);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          focusNode: _discountPercentLevel1FocusNode,
                          decoration: const InputDecoration(
                              hintText: 'Percent Level 1'),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onSaved: (value) => _discountPercentLevel1 =
                              value != null && value.isNotEmpty
                                  ? double.parse(value)
                                  : null,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_discountPercentLevel2FocusNode);
                          },
                        ),
                      ),
                    ],
                  ),
                  // Level 2 Row
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          focusNode: _discountQuantityLevel2FocusNode,
                          decoration:
                              const InputDecoration(hintText: 'Qty Level 2'),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onSaved: (value) => _discountQuantityLevel2 =
                              value != null && value.isNotEmpty
                                  ? double.parse(value)
                                  : null,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_discountValueLevel1FocusNode);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          focusNode: _discountValueLevel2FocusNode,
                          decoration:
                              const InputDecoration(hintText: 'Value Level 2'),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onSaved: (value) => _discountValueLevel2 =
                              value != null && value.isNotEmpty
                                  ? double.parse(value)
                                  : null,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_discountPercentLevel1FocusNode);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          focusNode: _discountPercentLevel2FocusNode,
                          decoration: const InputDecoration(
                              hintText: 'Percent Level 2'),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onSaved: (value) => _discountPercentLevel2 =
                              value != null && value.isNotEmpty
                                  ? double.parse(value)
                                  : null,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_addNextButtonFocusNode);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      focusNode: _addNextButtonFocusNode,
                      onPressed: _addNextItem,
                      child: const Text('Add Next Item'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveItem,
                      child: const Text('Save Item'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
