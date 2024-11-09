// modules/transaction/payment_screen.dart

import 'package:flutter/material.dart';
import 'package:swiftstock_app/modules/transaction/transaction_model.dart';
import 'package:swiftstock_app/modules/transaction/transaction_service.dart';
import 'package:swiftstock_app/modules/transaction/transaction_complete_screen.dart';
import 'package:swiftstock_app/modules/transaction/cart_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;

  const PaymentScreen({Key? key, required this.totalAmount}) : super(key: key);

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  double _amountPaid = 0.0;

  void _completeTransaction() async {
    double balance = _amountPaid - widget.totalAmount;

    // Save transaction to database
    TransactionModel transaction = TransactionModel(
      items: cartItems,
      totalAmount: widget.totalAmount,
      amountPaid: _amountPaid,
      dateTime: DateTime.now(),
    );

    TransactionService transactionService = TransactionService();
    await transactionService.insertTransaction(transaction);

    // Clear the cart
    setState(() {
      cartItems.clear();
    });

    // Navigate to transaction completion screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionCompleteScreen(balance: balance),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Total Amount: ${widget.totalAmount.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Amount Paid',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  if (double.parse(value) < widget.totalAmount) {
                    return 'Amount paid cannot be less than total amount';
                  }
                  return null;
                },
                onSaved: (value) {
                  _amountPaid = double.parse(value!);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                ),
                child: const Text(
                  'Complete Transaction',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _completeTransaction();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
