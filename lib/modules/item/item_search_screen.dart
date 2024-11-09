// item_search_screen.dart

import 'package:flutter/material.dart';
import 'package:swiftstock_app/main.dart' show routeObserver; 
import 'package:swiftstock_app/services/service_locator.dart';
import 'package:swiftstock_app/widgets/custom_drawer.dart';
import 'dart:async';
import 'package:swiftstock_app/widgets/custom_keyboard.dart';
import 'package:swiftstock_app/modules/item/item_model.dart';
import 'package:swiftstock_app/services/database_service.dart';
import 'package:swiftstock_app/modules/transaction/cart_screen.dart';
import 'package:swiftstock_app/modules/transaction/transaction_model.dart';


class ItemSearchScreen extends StatefulWidget {
  const ItemSearchScreen({super.key});
  @override
  ItemSearchScreenState createState() => ItemSearchScreenState();
}

class ItemSearchScreenState extends State<ItemSearchScreen> with RouteAware {
  List<GroupedItem> allGroupedItems = [];
  List<GroupedItem> displayedGroupedItems = [];
  TextEditingController _searchController = TextEditingController();
  Map<GroupedItem, TextEditingController> _quantityControllers = {};
  Map<GroupedItem, Timer?> _debounceTimers = {};
  Map<GroupedItem, FocusNode> _quantityFocusNodes = {};
  bool _isProgrammaticallyClearing = false;

  // Variables for custom keyboard
  bool _useCustomKeyboard = false;
  bool _showCustomKeyboard = true;
  int _keyboardThreshold = 1;
  List<String> _currentKeyboardKeys = [];

  @override
  void initState() {
    super.initState();

    _loadItems();
    _loadSettings();
  }

  void _loadSettings() async {
    dynamic useCustomKeyboardValue =
        await locator<DatabaseService>().sharedInstance.getSetting('useCustomKeyboard');
    dynamic keyboardThresholdValue =
        await locator<DatabaseService>().sharedInstance.getSetting('keyboardThreshold');
    setState(() {
      _useCustomKeyboard = useCustomKeyboardValue ?? false;
      _keyboardThreshold = keyboardThresholdValue ?? 1;
    });
    if (_useCustomKeyboard) {
      _updateKeyboardKeys();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route observer
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    // Unsubscribe from route observer
    routeObserver.unsubscribe(this);
    // Dispose of all quantity controllers
    _quantityControllers.values.forEach((controller) {
      controller.dispose();
    });
    // Dispose of all FocusNodes
    _quantityFocusNodes.values.forEach((focusNode) {
      focusNode.dispose();
    });
    // Dispose of other controllers
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    // Reload items and settings when coming back
    _loadItems();
    _loadSettings();
  }

  void _loadItems() async {
  List<Item> items = await locator<DatabaseService>().sharedInstance.getAllItems();

  // Group items by displayName (keeping this unchanged)
  Map<String, GroupedItem> groupedItemsMap = {};

  for (var item in items) {
    if (groupedItemsMap.containsKey(item.displayName)) {
      groupedItemsMap[item.displayName]!.items.add(item);
      groupedItemsMap[item.displayName]!.totalQuantity += item.quantityLeft;
    } else {
      groupedItemsMap[item.displayName] = GroupedItem(
        displayName: item.displayName,
        items: [item],
        totalQuantity: item.quantityLeft,
      );
    }
  }

  List<GroupedItem> groupedItems = groupedItemsMap.values.toList();


  await Future.wait(groupedItems.map((groupedItem) async {
      String englishName = groupedItem.items.last.englishName;
      groupedItem.mostUsedQuantities =
          await locator<DatabaseService>().sharedInstance.getMostUsedQuantitiesForEnglishName(englishName);
    }));
    
  setState(() {
    allGroupedItems = groupedItems;
  });

  if (_useCustomKeyboard) {
    _updateKeyboardKeys();
  }
}

  void _updateKeyboardKeys() {
    Set<String> possibleLetters = {};
    String currentInput = _searchController.text.toLowerCase();

    if (currentInput.isEmpty) {
      for (var groupedItem in allGroupedItems) {
        for (var item in groupedItem.items) {
          if (item.searchingName.isNotEmpty) {
            possibleLetters.add(item.searchingName[0].toLowerCase());
          }
        }
      }
    } else {
      List<GroupedItem> filteredItems = allGroupedItems.where((groupedItem) {
        return groupedItem.items.any((item) =>
            item.searchingName.toLowerCase().startsWith(currentInput));
      }).toList();

      for (var groupedItem in filteredItems) {
        for (var item in groupedItem.items) {
          String name = item.searchingName.toLowerCase();
          if (name.length > currentInput.length) {
            possibleLetters.add(name[currentInput.length]);
          }
        }
      }
    }

    setState(() {
      _currentKeyboardKeys = possibleLetters.toList()..sort();

      if (_currentKeyboardKeys.length <= _keyboardThreshold) {
        _showCustomKeyboard = false;
      } else {
        _showCustomKeyboard = true;
      }
    });
  }

  void _onKeyTap(String key) {
    _searchController.text += key;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: _searchController.text.length),
    );
    _filterItems(_searchController.text);
    _updateKeyboardKeys();
  }

  void _onBackspaceTap() {
    if (_searchController.text.isNotEmpty) {
      setState(() {
        _searchController.text = _searchController.text
            .substring(0, _searchController.text.length - 1);
        _searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: _searchController.text.length),
        );
      });
      _filterItems(_searchController.text);
      if (_useCustomKeyboard) {
        _updateKeyboardKeys();
      }
    }
  }

  void _filterItems(String query) {
    if (_isProgrammaticallyClearing) {
      return;
    }

    if (query.isNotEmpty) {
      List<GroupedItem> matchingItems = allGroupedItems.where((groupedItem) {
        return groupedItem.items.any((item) =>
            item.searchingName.toLowerCase().contains(query.toLowerCase()));
      }).toList();

      List<GroupedItem> startsWithQuery = matchingItems.where((groupedItem) {
        return groupedItem.items.any((item) =>
            item.searchingName.toLowerCase().startsWith(query.toLowerCase()));
      }).toList();

      List<GroupedItem> containsQuery = matchingItems.where((groupedItem) {
        return !groupedItem.items.any((item) =>
            item.searchingName.toLowerCase().startsWith(query.toLowerCase()));
      }).toList();

      startsWithQuery
          .sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));
      containsQuery.sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));

      setState(() {
        displayedGroupedItems = startsWithQuery + containsQuery;
      });
    } else {}

    if (_useCustomKeyboard) {
      _updateKeyboardKeys();
    }
  }

  List<double> _getMostUsedQuantities(GroupedItem groupedItem) {
    if (groupedItem.mostUsedQuantities.isNotEmpty) {
      return groupedItem.mostUsedQuantities;
    } else {
      return [1.0, 2.0, 5.0];
    }
  }

  List<Widget> _buildQuantityButtons(GroupedItem groupedItem) {
    List<double> quantities = _getMostUsedQuantities(groupedItem);

    return quantities.map((quantity) {
      return ElevatedButton(
        child: Text('${quantity}${groupedItem.items.first.unit}'),
        onPressed: () {
          _addItemToCart(groupedItem, quantity.toString());
        },
      );
    }).toList();
  }

  void _addItemToCart(GroupedItem groupedItem, String? quantityText) {
    debugPrint(
        'Adding grouped item to cart: ${groupedItem.displayName} with quantity: $quantityText');
    double? quantity = double.tryParse(quantityText ?? '');
    if (quantity != null && quantity > 0) {
      List<Item> itemsByExpiry = List.from(groupedItem.items)
        ..sort((a, b) => a.expireDate!.compareTo(b.expireDate!));

      double remainingQuantity = quantity;
      List<TransactionItem> itemsToAddToCart = [];

      for (var item in itemsByExpiry) {
        if (item.quantityLeft <= 0) continue;

        double quantityTaken = item.quantityLeft >= remainingQuantity
            ? remainingQuantity
            : item.quantityLeft;
        // discount logic
        double adjustedPricePerUnit = item.sellPricePerUnit;
        double? discountAmount;
        double? discountPercent;
        bool isDiscountPercent = false;

        // Calculate discount
        double? discountQuantityLevel1 = item.discountQuantityLevel1;
        double? discountQuantityLevel2 = item.discountQuantityLevel2;

        if (discountQuantityLevel2 != null &&
            quantity >= discountQuantityLevel2) {
          // Apply level 2 discount
          if (item.discountValueLevel2 != null) {
            discountAmount = item.discountValueLevel2!;
            adjustedPricePerUnit -= discountAmount;
            isDiscountPercent = false;
          } else if (item.discountPercentLevel2 != null) {
            discountPercent = item.discountPercentLevel2!;
            adjustedPricePerUnit *= (1 - discountPercent / 100);
            isDiscountPercent = true;
          }
        } else if (discountQuantityLevel1 != null &&
            quantity >= discountQuantityLevel1) {
          // Apply level 1 discount
          if (item.discountValueLevel1 != null) {
            discountAmount = item.discountValueLevel1!;
            adjustedPricePerUnit -= discountAmount;
            isDiscountPercent = false;
          } else if (item.discountPercentLevel1 != null) {
            discountPercent = item.discountPercentLevel1!;
            adjustedPricePerUnit *= (1 - discountPercent / 100);
            isDiscountPercent = true;
          }
        }

        if (adjustedPricePerUnit < 0) {
          adjustedPricePerUnit = 0;
        }

        itemsToAddToCart.add(TransactionItem(
          item: item,
          quantity: quantityTaken,
          adjustedPrice: adjustedPricePerUnit,
          unit: item.unit,
          discountAmount: discountAmount,
          discountPercent: discountPercent,
          isDiscountPercent: isDiscountPercent,
        ));

        remainingQuantity -= quantityTaken;

        if (remainingQuantity <= 0) break;
      }

      if (remainingQuantity > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Insufficient quantity available for ${groupedItem.displayName}. Available: ${(quantity - remainingQuantity).toStringAsFixed(2)}')),
        );
        return;
      }

      cartItems.removeWhere((cartItem) =>
          groupedItem.items.any((item) => item.id == cartItem.item?.id));

      setState(() {
        cartItems.addAll(itemsToAddToCart);
      });

      setState(() {
        _quantityControllers[groupedItem]?.clear();
      });

      _isProgrammaticallyClearing = true;
      _searchController.clear();
      _isProgrammaticallyClearing = false;

      if (_useCustomKeyboard) {
        _updateKeyboardKeys();
      }
    } else {
      cartItems.removeWhere((cartItem) =>
          groupedItem.items.any((item) => item.id == cartItem.item?.id));
    }
  }

  double? _getCartItemQuantity(GroupedItem groupedItem) {
    double totalQuantity = 0.0;
    for (var cartItem in cartItems) {
      if (groupedItem.items.any((item) => item.id == cartItem.item?.id)) {
        totalQuantity += cartItem.quantity;
      }
    }
    return totalQuantity > 0 ? totalQuantity : null;
  }

  @override
  Widget build(BuildContext context) {
    double keyboardHeight =
        (_useCustomKeyboard && _showCustomKeyboard) ? 250.0 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Item'),
      ),
      drawer: CustomDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              labelText: 'Search Item',
                            ),
                            readOnly: _useCustomKeyboard,
                            onChanged: (value) {
                              _filterItems(value);
                              if (_useCustomKeyboard) {
                                _updateKeyboardKeys();
                              }
                            },
                          ),
                        ),
                        Visibility(
                          visible: _useCustomKeyboard,
                          child: IconButton(
                            icon: const Icon(Icons.backspace),
                            onPressed: _onBackspaceTap,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 60),
                      ),
                      child: const Text(
                        'Finish',
                        style: TextStyle(fontSize: 18),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CartScreen()),
                        ).then((_) {
                          _loadItems();
                          _loadSettings();
                        });
                      },
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: keyboardHeight),
                  child: ListView.builder(
                    itemCount: displayedGroupedItems.length,
                    itemBuilder: (context, index) {
                      final groupedItem = displayedGroupedItems[index];
                      double? cartQuantity = _getCartItemQuantity(groupedItem);

                      if (!_quantityFocusNodes.containsKey(groupedItem)) {
                        final focusNode = FocusNode();
                        focusNode.addListener(() {
                          if (focusNode.hasFocus) {
                            setState(() {
                              _showCustomKeyboard = false;
                            });
                          } else {
                            setState(() {
                              if (_useCustomKeyboard &&
                                  _currentKeyboardKeys.length >
                                      _keyboardThreshold) {
                                _showCustomKeyboard = true;
                              }
                            });
                          }
                        });
                        _quantityFocusNodes[groupedItem] = focusNode;
                      }

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cartQuantity != null
                                    ? '${groupedItem.displayName} - Added: ${cartQuantity}${groupedItem.items.first.unit}'
                                    : groupedItem.displayName,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Wrap(
                                      spacing: 8.0,
                                      alignment: WrapAlignment.start,
                                      children:
                                          _buildQuantityButtons(groupedItem),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      focusNode:
                                          _quantityFocusNodes[groupedItem],
                                      controller:
                                          _quantityControllers[groupedItem] ??=
                                              TextEditingController(),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      decoration: const InputDecoration(
                                        hintText: 'Qty',
                                        contentPadding:
                                            EdgeInsets.symmetric(horizontal: 8),
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        if (_debounceTimers[groupedItem] !=
                                            null) {
                                          _debounceTimers[groupedItem]
                                              ?.cancel();
                                        }
                                        _debounceTimers[groupedItem] = Timer(
                                            const Duration(milliseconds: 800),
                                            () {
                                          _addItemToCart(groupedItem, value);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          if (_useCustomKeyboard && _showCustomKeyboard)
            Align(
              alignment: Alignment.bottomCenter,
              child: CustomKeyboard(
                keys: _currentKeyboardKeys,
                onKeyTap: _onKeyTap,
              ),
            ),
        ],
      ),
    );
  }
}


class GroupedItem {
  String displayName;
  List<Item> items; // List of items with the same displayName
  double totalQuantity;
  List<double> mostUsedQuantities;

  GroupedItem({
    required this.displayName,
    
    required this.items,
    this.totalQuantity = 0.0,
    this.mostUsedQuantities = const [],
  });
}
