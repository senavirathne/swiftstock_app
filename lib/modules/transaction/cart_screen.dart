// modules/transaction/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:swiftstock_app/modules/transaction/transaction_model.dart';
import 'package:swiftstock_app/modules/transaction/payment_screen.dart';
import 'add_custom_item_screen.dart';
import 'package:flutter/widgets.dart' as flutter;

// Global cart items list
List<TransactionItem> cartItems = [];

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  double _calculateTotal() {
    double total = 0.0;
    for (var item in cartItems) {
      double price = item.adjustedPrice;
      double qty = item.quantity;
      total += price * qty;
    }

    return total;
  }

  void _editItemQuantity(TransactionItem transactionItem) {
    TextEditingController _quantityController =
        TextEditingController(text: transactionItem.quantity.toString());
    TextEditingController _priceController =
        TextEditingController(text: transactionItem.adjustedPrice.toString());
    bool isDiscountPercent = transactionItem.isDiscountPercent;
    double? discountAmount = transactionItem.discountAmount;
    double? discountPercent = transactionItem.discountPercent;
    TextEditingController _discountController = TextEditingController(
        text: isDiscountPercent
            ? discountPercent?.toString() ?? '0'
            : discountAmount?.toString() ?? '0');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(
                'Edit Item: ${transactionItem.item?.displayName ?? transactionItem.customItemName}'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _quantityController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                    ),
                  ),
                  TextField(
                    controller: _priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Price per Unit',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Apply Discount As:'),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Value'),
                          value: false,
                          groupValue: isDiscountPercent,
                          onChanged: (value) {
                            setState(() {
                              isDiscountPercent = value!;
                              _discountController.text = isDiscountPercent
                                  ? discountPercent?.toString() ?? '0'
                                  : discountAmount?.toString() ?? '0';
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Percent'),
                          value: true,
                          groupValue: isDiscountPercent,
                          onChanged: (value) {
                            setState(() {
                              isDiscountPercent = value!;
                              _discountController.text = isDiscountPercent
                                  ? discountPercent?.toString() ?? '0'
                                  : discountAmount?.toString() ?? '0';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: _discountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: isDiscountPercent
                          ? 'Discount Percent (%)'
                          : 'Discount Amount',
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (isDiscountPercent) {
                          discountPercent = double.tryParse(value);
                          discountAmount = 0;
                        } else {
                          discountAmount = double.tryParse(value);
                          discountPercent = 0;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('Save'),
                onPressed: () {
                  double? newQuantity =
                      double.tryParse(_quantityController.text);
                  double? newPricePerUnit =
                      double.tryParse(_priceController.text);
                  if (newQuantity != null &&
                      newQuantity > 0 &&
                      newPricePerUnit != null &&
                      newPricePerUnit >= 0) {
                    // Recalculate discount based on the new quantity

                    if (discountAmount != null && discountAmount! > 0) {
                      newPricePerUnit -= discountAmount!;
                      isDiscountPercent = false;
                    } else if (discountPercent != null && discountPercent! > 0) {
                      newPricePerUnit *= (1 - discountPercent! / 100);
                      isDiscountPercent = true;
                    }

                    setState(() {
                      transactionItem.quantity = newQuantity;
                      transactionItem.adjustedPrice = newPricePerUnit!;
                      transactionItem.isDiscountPercent = isDiscountPercent;
                      transactionItem.discountAmount = discountAmount;
                      transactionItem.discountPercent = discountPercent;
                    });
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => CartScreen()),
                    );
                    debugPrint('Step 47: Saved new quantity: $newQuantity');
                  } else {
                    debugPrint('Step 48: Invalid quantity or price entered');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Please enter valid quantity and price')),
                    );
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = _calculateTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Items'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length + 1,
              itemBuilder: (context, index) {
                if (index < cartItems.length) {
                  final transactionItem = cartItems[index];
                  return ListTile(
                    title: Text(
                        '${transactionItem.item?.displayName ?? transactionItem.customItemName} ${transactionItem.quantity}${transactionItem.item?.unit ?? transactionItem.unit ?? ''}'),
                    subtitle: transactionItem.discountAmount != null ||
                            transactionItem.discountPercent != null
                        ? Text(
                            'Discount Applied: ${transactionItem.isDiscountPercent ? '${transactionItem.discountPercent}% off' : '${transactionItem.discountAmount} off per unit'}')
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _editItemQuantity(transactionItem);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              cartItems.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  return ListTile(
                    title: const Center(child: Text('Add Custom Item')),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddCustomItemScreen()),
                      ).then((_) => setState(() {}));
                    },
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Total Amount: ${totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          flutter.Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
              ),
              child: const Text(
                'Proceed to Payment',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PaymentScreen(totalAmount: totalAmount),
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
