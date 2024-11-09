// modules/transaction/add_custom_item_screen.dart

import 'package:flutter/material.dart';
import 'package:swiftstock_app/modules/transaction/transaction_model.dart';
// import 'package:swiftstock_app/global/cart_items.dart'; // Assuming cartItems is defined here
import 'cart_screen.dart';

class AddCustomItemScreen extends StatefulWidget {
  const AddCustomItemScreen({Key? key}) : super(key: key);

  @override
  _AddCustomItemScreenState createState() => _AddCustomItemScreenState();
}

class _AddCustomItemScreenState extends State<AddCustomItemScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form input variables
  String _itemName = '';
  double _pricePerUnit = 0.0;
  double _quantity = 1.0;
  String _unit = '';

  // Method to add the custom item to the cart
  void _addCustomItem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Create a TransactionItem with custom item details
      TransactionItem transactionItem = TransactionItem(
        item: null, // No associated Item from the database
        itemId: null,
        customItemName: _itemName,
        unit: _unit,
        quantity: _quantity,
        adjustedPrice: _pricePerUnit,
      );

      // Add to the cart
      setState(() {
        cartItems.add(transactionItem);
      });

      debugPrint('Added custom item to cart: $_itemName');

      // Navigate back to the CartScreen
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building AddCustomItemScreen');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Custom Item'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              // Item Name Field
              TextFormField(
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter item name'
                    : null,
                onSaved: (value) => _itemName = value!,
              ),
              const SizedBox(height: 16),

              // Unit Field
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Unit (e.g., kg, unit)'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter unit' : null,
                onSaved: (value) => _unit = value!,
              ),
              const SizedBox(height: 16),

              // Price per Unit Field
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price per Unit'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => (value == null ||
                        double.tryParse(value) == null ||
                        double.parse(value) <= 0)
                    ? 'Please enter valid price'
                    : null,
                onSaved: (value) => _pricePerUnit = double.parse(value!),
              ),
              const SizedBox(height: 16),

              // Quantity Field
              TextFormField(
                decoration: const InputDecoration(labelText: 'Quantity'),
                initialValue: '1',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => (value == null ||
                        double.tryParse(value) == null ||
                        double.parse(value) <= 0)
                    ? 'Please enter valid quantity'
                    : null,
                onSaved: (value) => _quantity = double.parse(value!),
              ),
              const SizedBox(height: 16),

              // Add Item Button
              ElevatedButton(
                child: const Text('Add Item'),
                onPressed: _addCustomItem,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
