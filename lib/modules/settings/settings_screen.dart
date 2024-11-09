// modules/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swiftstock_app/modules/item/edit_items_screen.dart';
import 'package:swiftstock_app/services/service_locator.dart';
import 'package:swiftstock_app/services/settings_service.dart';
import 'package:swiftstock_app/services/import_service.dart';
import 'package:swiftstock_app/modules/item/add_item_screen.dart';
import 'package:csv/csv.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _modItemsController = TextEditingController();
  final TextEditingController _csvInputController = TextEditingController();
  final TextEditingController _keyboardThresholdController =
      TextEditingController();

  final SettingsService _settingsService = locator<SettingsService>();
  final ImportService _importService = locator<ImportService>();

  bool _useCustomKeyboard = false;
  int _keyboardThreshold = 1;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    dynamic useCustomKeyboardValue =
        await _settingsService.getSetting('useCustomKeyboard');
    dynamic keyboardThresholdValue =
        await _settingsService.getSetting('keyboardThreshold');

    setState(() {
      _useCustomKeyboard = useCustomKeyboardValue ?? false;
      _keyboardThreshold = keyboardThresholdValue ?? 1;
      _keyboardThresholdController.text = _keyboardThreshold.toString();

      int numberOfModItems = _settingsService.getNumberOfModItems();
      _modItemsController.text = numberOfModItems.toString();
    });
  }

  void _saveUseCustomKeyboard(bool value) async {
    await _settingsService.saveSetting('useCustomKeyboard', value);
    setState(() {
      _useCustomKeyboard = value;
    });
  }

  void _saveKeyboardThreshold() async {
    int threshold = int.tryParse(_keyboardThresholdController.text.trim()) ?? 1;
    if (threshold < 0) threshold = 0;
    await _settingsService.saveSetting('keyboardThreshold', threshold);
    setState(() {
      _keyboardThreshold = threshold;
    });
  }

  void _saveModItems() {
    int number = int.tryParse(_modItemsController.text.trim()) ?? 5;
    number = number > 0 ? number : 5;
    _settingsService.setNumberOfModItems(number);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved Mod Items: $number')),
    );
  }

  Future<void> _importCsvFromInput() async {
    String csvString = _csvInputController.text;

    if (csvString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter CSV data to import')),
      );
      return;
    }

    ImportResult result = await _importService.importCsvData(csvString);

    String message = 'Import completed.\n'
        'Successfully imported/updated: ${result.successCount} items.\n'
        'Failed to import: ${result.failureCount} items.\n'
        'Errors:\n${result.errorMessages.join('\n')}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Status'),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _copyAndClearDatabase() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text(
            'Are you sure you want to copy and clear the database? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (!confirm) return;

    try {
      await _importService.copyDataAndClearDatabase();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Database data copied and database cleared')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _showDataAsCsv() async {
    String csvString = await _importService.exportDataAsCsv();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data in CSV Format'),
        content: SingleChildScrollView(
          child: SelectableText(csvString),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _copyOrdersAsCSV() async {
    String csv = await _importService.exportOrdersAsCsv();

    Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Order details copied to clipboard in CSV format')),
    );
  }

  Future<void> _addNewItem() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddItemScreen()),
    );
    setState(() {});
  }
  Future<void> _editItems() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditItemsScreen()),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Number of Mod Items to Show',
            style: TextStyle(fontSize: 18),
          ),
          TextField(
            controller: _modItemsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'e.g., 5',
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _saveModItems,
            child: const Text('Save Settings'),
          ),
          const Divider(),
          Row(
            children: [
              const Text('Use Custom Keyboard'),
              Switch(
                value: _useCustomKeyboard,
                onChanged: (bool value) {
                  _saveUseCustomKeyboard(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _keyboardThresholdController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Keyboard Hide Threshold',
              hintText: 'Threshold',
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _saveKeyboardThreshold,
            child: const Text('Save Keyboard Settings'),
          ),
          const Divider(),
          const Text(
            'Import CSV Data',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _csvInputController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'CSV Data',
              hintText: 'Paste CSV data here',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _importCsvFromInput,
            child: const Text('Import from CSV Input'),
          ),
          const Divider(),
          ElevatedButton(
            onPressed: _showDataAsCsv,
            child: const Text('Show Data as CSV'),
          ),
          const Divider(),
          ElevatedButton(
            onPressed: _copyOrdersAsCSV,
            child: const Text('Copy Orders as CSV'),
          ),
          const Divider(),
          ElevatedButton(
            onPressed: _addNewItem,
            child: const Text('Add New Item'),
          ),
          const Divider(),
            ElevatedButton(
              onPressed: _editItems,
              child: const Text('Edit Existing Items'),
            ),
          const Divider(),
          ElevatedButton(
            onPressed: _copyAndClearDatabase,
            child: const Text('Copy & Clear Database'),
          ),
        ],
      ),
    );
  }
}
