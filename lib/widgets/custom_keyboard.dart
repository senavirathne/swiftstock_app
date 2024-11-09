// lib/widgets/custom_keyboard.dart
// Custom keyboard widget used in the item search screen.

import 'package:flutter/material.dart';

/// Callback type for when a key is tapped on the custom keyboard.
typedef KeyboardTapCallback = void Function(String text);

/// A custom keyboard widget that displays a set of keys and notifies when a key is tapped.
/// The keyboard layout is based on the standard QWERTY keyboard and dynamically displays
/// only the keys provided in the [keys] list.
class CustomKeyboard extends StatelessWidget {
  /// The list of keys to display on the keyboard.
  final List<String> keys;

  /// Callback function to be called when a key is tapped.
  final KeyboardTapCallback onKeyTap;

  const CustomKeyboard({
    Key? key,
    required this.keys,
    required this.onKeyTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define standard QWERTY keyboard rows as lists of strings.
    final List<String> numberRow = '1234567890'.split('');
    final List<String> row1 = 'qwertyuiop'.split('');
    final List<String> row2 = 'asdfghjkl'.split('');
    final List<String> row3 = 'zxcvbnm'.split('');

    // Filter keys based on the provided keys list.
    final List<String> availableNumberRow =
        numberRow.where((k) => keys.contains(k)).toList();
    final List<String> availableRow1 =
        row1.where((k) => keys.contains(k)).toList();
    final List<String> availableRow2 =
        row2.where((k) => keys.contains(k)).toList();
    final List<String> availableRow3 =
        row3.where((k) => keys.contains(k)).toList();

    // Function to build a row of keys.
    Widget buildRow(List<String> rowKeys) {
      if (rowKeys.isEmpty) return Container();

      return Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: rowKeys.map((key) {
            return Expanded(
              child: GestureDetector(
                onTap: () => onKeyTap(key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100), // Subtle animation for key press.
                  margin: const EdgeInsets.all(4), // Spacing between keys.
                  decoration: BoxDecoration(
                    color: Colors.white, // Key background color.
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners for keys.
                    border: Border.all(color: Colors.grey[400]!), // Key border color.
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4.0, // Shadow blur radius.
                        offset: const Offset(0, 2), // Shadow offset.
                      ),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate font size dynamically based on key height.
                      double fontSize = constraints.maxHeight * 0.5;
                      return Center(
                        child: Text(
                          key.toLowerCase(), // Display keys in lowercase.
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87, // Text color.
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    return Container(
      color: Colors.grey[300], // Keyboard background color.
      height: 250, // Fixed height for the keyboard.
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (availableNumberRow.isNotEmpty) buildRow(availableNumberRow),
          if (availableRow1.isNotEmpty) buildRow(availableRow1),
          if (availableRow2.isNotEmpty) buildRow(availableRow2),
          if (availableRow3.isNotEmpty) buildRow(availableRow3),
        ],
      ),
    );
  }
}
