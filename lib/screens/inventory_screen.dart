import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../models/inventory_item.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = '';
  String _sortBy = 'name'; // Options: 'name', 'quantity', 'threshold'
  bool _isAscending = true;

  List<InventoryItem> _sortItems(List<InventoryItem> items) {
    final sortedItems = List<InventoryItem>.from(items);
    switch (_sortBy) {
      case 'name':
        sortedItems.sort((a, b) => _isAscending
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
        break;
      case 'quantity':
        sortedItems.sort((a, b) => _isAscending
            ? a.quantity.compareTo(b.quantity)
            : b.quantity.compareTo(a.quantity));
        break;
      case 'threshold':
        sortedItems.sort((a, b) => _isAscending
            ? a.lowStockThreshold.compareTo(b.lowStockThreshold)
            : b.lowStockThreshold.compareTo(a.lowStockThreshold));
        break;
    }
    return sortedItems;
  }

  List<InventoryItem> _filterItems(List<InventoryItem> items) {
    if (_searchQuery.isEmpty) return items;
    return items
        .where((item) =>
            item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context);
    final shopId = appProvider.shopId;

    if (shopId == null) {
      return Center(child: Text(localizations.shopNotFound));
    }

    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: localizations.searchItems,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Sort Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _sortBy,
                  items: [
                    DropdownMenuItem(
                      value: 'name',
                      child: Text(localizations.sortByName),
                    ),
                    DropdownMenuItem(
                      value: 'quantity',
                      child: Text(localizations.sortByQuantity),
                    ),
                    DropdownMenuItem(
                      value: 'threshold',
                      child: Text(localizations.sortByThreshold),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  ),
                  tooltip: localizations.sortOrderTooltip,
                  onPressed: () {
                    setState(() {
                      _isAscending = !_isAscending;
                    });
                  },
                ),
              ],
            ),
          ),

          // Low Stock Alerts
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                localizations.lowStockAlert,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          Expanded(
            child: Consumer<AppProvider>(
              builder: (context, provider, child) {
                final lowStockItems = provider.lowStockItems;
                if (lowStockItems.isEmpty) {
                  return Center(child: Text(localizations.noItems));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: lowStockItems.length,
                  itemBuilder: (context, index) {
                    final item = lowStockItems[index];
                    return Card(
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                          '${localizations.quantity}: ${item.quantity} | Threshold: ${item.lowStockThreshold}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditItemDialog(context, provider, item);
                          },
                          tooltip: localizations.editItem,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // All Inventory Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                localizations.itemsScreenTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          Expanded(
            child: Consumer<AppProvider>(
              builder: (context, provider, child) {
                final filteredItems = _filterItems(provider.inventory);
                final sortedItems = _sortItems(filteredItems);
                if (sortedItems.isEmpty) {
                  return Center(child: Text(localizations.noItems));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: sortedItems.length,
                  itemBuilder: (context, index) {
                    final item = sortedItems[index];
                    return Card(
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                          '${localizations.quantity}: ${item.quantity} | Threshold: ${item.lowStockThreshold}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditItemDialog(context, provider, item);
                          },
                          tooltip: localizations.editItem,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, AppProvider provider, InventoryItem item) {
    final localizations = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: item.name);
    final quantityController = TextEditingController(text: item.quantity.toString());
    final buyPriceController = TextEditingController(text: item.buyPrice.toString());
    final sellPriceController = TextEditingController(text: item.sellPrice.toString());
    final thresholdController = TextEditingController(text: item.lowStockThreshold.toString());
    bool isSellable = item.isSellable;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.editItem),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: localizations.item),
                ),
                TextField(
                  controller: quantityController,
                  decoration: InputDecoration(labelText: localizations.quantity),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: buyPriceController,
                  decoration: InputDecoration(labelText: 'Buy Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: sellPriceController,
                  decoration: InputDecoration(labelText: 'Sell Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: thresholdController,
                  decoration: InputDecoration(labelText: 'Low Stock Threshold'),
                  keyboardType: TextInputType.number,
                ),
                SwitchListTile(
                  title: const Text('Sellable'),
                  value: isSellable,
                  onChanged: (value) {
                    isSellable = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () async {
                final updatedItem = InventoryItem(
                  id: item.id,
                  name: nameController.text,
                  quantity: double.tryParse(quantityController.text) ?? item.quantity,
                  buyPrice: double.tryParse(buyPriceController.text) ?? item.buyPrice,
                  sellPrice: double.tryParse(sellPriceController.text) ?? item.sellPrice,
                  lowStockThreshold: double.tryParse(thresholdController.text) ?? item.lowStockThreshold,
                  isSellable: isSellable,
                );
                await provider.updateInventoryItem(updatedItem);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(localizations.saveSuccessMessage)),
                );
              },
              child: Text(localizations.save),
            ),
          ],
        );
      },
    );
  }
}