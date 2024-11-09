// services/import_service.dart

import 'package:flutter/material.dart';
import 'package:swiftstock_app/modules/item/item_model.dart';
import 'package:swiftstock_app/modules/transaction/transaction_model.dart';
import 'package:swiftstock_app/services/service_locator.dart';
import 'database_service.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

abstract class ImportService {
  Future<ImportResult> importCsvData(String csvString);
  Future<String> exportDataAsCsv();
  Future<String> exportOrdersAsCsv();
  Future<void> copyDataAndClearDatabase();
}

class ImportResult {
  final int successCount;
  final int failureCount;
  final List<String> errorMessages;

  ImportResult({
    required this.successCount,
    required this.failureCount,
    required this.errorMessages,
  });
}

class RealImportService implements ImportService {
  final DatabaseService? _databaseService = locator<DatabaseService>();

  @override
  Future<ImportResult> importCsvData(String csvString) async {
    if (_databaseService == null) {
      return ImportResult(successCount: 0, failureCount: 0, errorMessages: [
        'Database service is not available.',
      ]);
    }

    List<List<dynamic>> csvData =
        const CsvToListConverter(eol: '\n').convert(csvString);

    int successCount = 0;
    int failureCount = 0;
    List<String> errorMessages = [];

    for (var row in csvData.skip(1)) {
      if (row.length < 17) {
        failureCount++;
        errorMessages.add('Row has insufficient columns: $row');
        continue;
      }

      try {
        String englishName = row[0]?.toString() ?? '';
        String displayName = row[1]?.toString() ?? '';
        String searchingName = row[2]?.toString() ?? '';
        double buyPricePerUnit =
            double.tryParse(row[3]?.toString() ?? '') ?? 0.0;
        double sellPricePerUnit =
            double.tryParse(row[4]?.toString() ?? '') ?? 0.0;
        String unit = row[5]?.toString() ?? '';
        String expireDateStr = row[6]?.toString() ?? '';
        DateTime? expireDate =
            expireDateStr.isNotEmpty ? DateTime.tryParse(expireDateStr) : null;
        String addedDateStr = row[7]?.toString() ?? '';
        DateTime? addedDate =
            addedDateStr.isNotEmpty ? DateTime.tryParse(addedDateStr) : null;

        double initialQuantity = double.tryParse(row[8]?.toString() ?? '') ?? 0.0;
        double quantity = double.tryParse(row[9]?.toString() ?? '') ?? 0.0;

        int frequency = int.tryParse(row[10]?.toString() ?? '') ?? 0;

        double? discountQuantityLevel1 =
            double.tryParse(row[11]?.toString() ?? '');
        double? discountQuantityLevel2 =
            double.tryParse(row[12]?.toString() ?? '');
        double? discountValueLevel1 =
            double.tryParse(row[13]?.toString() ?? '');
        double? discountValueLevel2 =
            double.tryParse(row[14]?.toString() ?? '');
        double? discountPercentLevel1 =
            double.tryParse(row[14]?.toString() ?? '');
        double? discountPercentLevel2 =
            double.tryParse(row[16]?.toString() ?? '');
        searchingName = searchingName.replaceAll(' ', '');
        if (englishName.isEmpty ||
            displayName.isEmpty ||
            searchingName.isEmpty ||
            unit.isEmpty) {
          throw Exception('Required fields are missing');
        }

        // Get all items that match the `englishName`
        List<Item> matchingItems =
            await _databaseService!.getItemsByEnglishName(englishName);

        bool inserted = !matchingItems.isEmpty &&
            matchingItems.any((existingItem) =>
                existingItem.searchingName == searchingName &&
                existingItem.buyPricePerUnit == buyPricePerUnit &&
                existingItem.sellPricePerUnit == sellPricePerUnit &&
                existingItem.unit == unit &&
                existingItem.expireDate == expireDate &&
                existingItem.addedDate == addedDate &&
                existingItem.quantityLeft == quantity);
        if (!inserted) {
          Item item = Item(
            englishName: englishName,
            displayName: displayName,
            searchingName: searchingName,
            buyPricePerUnit: buyPricePerUnit,
            sellPricePerUnit: sellPricePerUnit,
            unit: unit,
            expireDate: expireDate,
            addedDate: addedDate,
            quantityLeft: quantity,
            initialQuantity: initialQuantity,
            frequency: frequency,
            discountQuantityLevel1: discountQuantityLevel1,
            discountQuantityLevel2: discountQuantityLevel2,
            discountValueLevel1: discountValueLevel1,
            discountValueLevel2: discountValueLevel2,
            discountPercentLevel1: discountPercentLevel1,
            discountPercentLevel2: discountPercentLevel2,
          );

          await _databaseService!.insertItem(item);
          successCount++;
        }
      } catch (e) {
        failureCount++;
        errorMessages.add('Failed to import row: $row. Error: $e');
      }
    }

    return ImportResult(
      successCount: successCount,
      failureCount: failureCount,
      errorMessages: errorMessages,
    );
  }

  @override
  Future<String> exportDataAsCsv() async {
    if (_databaseService == null) {
      return 'Database service is not available.';
    }

    List<Item> items = await _databaseService!.getAllItems();

    List<List<dynamic>> csvData = [
      [
        'EnglishName',
        'DisplayName',
        'SearchingName',
        'BuyPricePerUnit',
        'SellPricePerUnit',
        'Unit',
        'ExpireDate',
        'AddedDate',
        'InitialQuantity',
        'QuantityLeft',
        'Frequency',
        'DiscountQuantityLevel1',
        'DiscountQuantityLevel2',
        'DiscountValueLevel1',
        'DiscountValueLevel2',
        'DiscountPercentLevel1',
        'DiscountPercentLevel2',
      ],
      ...items.map((item) => [
            item.englishName,
            item.displayName,
            item.searchingName,
            item.buyPricePerUnit,
            item.sellPricePerUnit,
            item.unit,
            item.expireDate?.toIso8601String(),
            item.addedDate?.toIso8601String(),
            item.initialQuantity,
            item.quantityLeft,
            item.frequency,
            item.discountQuantityLevel1,
            item.discountQuantityLevel2,
            item.discountValueLevel1,
            item.discountValueLevel2,
            item.discountPercentLevel1,
            item.discountPercentLevel2,
          ])
    ];

    String csvString = const ListToCsvConverter().convert(csvData);
    return csvString;
  }

  @override
  Future<String> exportOrdersAsCsv() async {
    if (_databaseService == null) {
      return 'Database service is not available.';
    }

    List<TransactionModel> orders =
        await _databaseService!.getAllTransactions();
    List<List<dynamic>> csvData = [
      [
        'Order ID',
        'Date',
        'Total Amount',
        'Amount Paid',
        'Item Name',
        'Quantity',
        'Price per Unit',
        'Discount',
        'Total Price'
      ]
    ];

    for (var order in orders) {
      for (var item in order.items) {
        String discountString = '';
        if (item.discountAmount != null) {
          discountString = '${item.discountAmount} off per unit';
        } else if (item.discountPercent != null) {
          discountString = '${item.discountPercent}% off';
        }

        csvData.add([
          order.id,
          order.dateTime.toLocal().toString().split(' ')[0],
          order.totalAmount.toStringAsFixed(2),
          order.amountPaid.toStringAsFixed(2),
          item.item?.englishName ?? item.customItemName ?? 'Unknown',
          item.quantity,
          item.adjustedPrice.toStringAsFixed(2),
          discountString,
          (item.quantity * item.adjustedPrice).toStringAsFixed(2)
        ]);
      }
    }

    String csv = const ListToCsvConverter().convert(csvData);
    return csv;
  }

  @override
  Future<void> copyDataAndClearDatabase() async {
    if (_databaseService == null) {
      throw Exception('Database service is not available.');
    }

    String csvData = await exportDataAsCsv();
    Clipboard.setData(ClipboardData(text: csvData));
    await _databaseService!.clearDatabase();
  }
}
