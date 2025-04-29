import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/inventory_item.dart';
import '../models/inventory_snapshot.dart';
import '../providers/app_provider.dart';

class InventoryTableScreen extends StatefulWidget {
  final String selectedDate;
  final String selectedTimeSlot;
  final String selectedWeather;

  const InventoryTableScreen({
    super.key,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.selectedWeather,
  });

  @override
  _InventoryTableScreenState createState() => _InventoryTableScreenState();
}

class _InventoryTableScreenState extends State<InventoryTableScreen> {
  Map<String, TextEditingController> quantityControllers = {};
  bool _isSaving = false;
  List<InventorySnapshot> _lastSavedSnapshots = [];
  String _searchQuery = '';
  String _sortBy = 'name'; // Default sort by name
  bool _sortAscending = true; // Default sort direction
  final Map<String, bool> _selectedItems = {}; // For bulk actions
  List<Map<String, String>> _lastClearedValues = []; // For undo

  @override
  void dispose() {
    quantityControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _saveAndSubmit(BuildContext context, AppProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.inventoryTitle),
        content: const Text(
            'Voulez-vous enregistrer les quantités et mettre à jour les ventes ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isSaving = true;
    });

    try {
      bool hasValidInput = false;
      _lastSavedSnapshots.clear();
      for (var item in provider.inventory) {
        final controller = quantityControllers[item.name]!;
        if (controller.text.isNotEmpty) {
          final quantity = double.parse(controller.text);
          if (quantity < 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Les quantités doivent être positives'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _isSaving = false;
            });
            return;
          }
          final snapshot = InventorySnapshot(
            id: const Uuid().v4(),
            itemId: item.id,
            quantity: quantity,
            timestamp: '${widget.selectedDate} ${widget.selectedTimeSlot}:00',
            timeSlot: widget.selectedTimeSlot,
            weather: widget.selectedWeather,
          );
          await provider.addSnapshot(snapshot); // Syncs to Firebase and SQLite
          _lastSavedSnapshots.add(snapshot);
          hasValidInput = true;
          controller.clear();
        }
      }

      if (!hasValidInput) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucune quantité valide à enregistrer'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      await provider.updateInventoryAndSales(widget.selectedDate, widget.selectedTimeSlot);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Quantités enregistrées et ventes mises à jour'),
          action: SnackBarAction(
            label: 'Annuler',
            onPressed: () async {
              for (var snapshot in _lastSavedSnapshots) {
                final item = provider.inventory
                    .firstWhere((i) => i.id == snapshot.itemId);
                final updatedItem = InventoryItem(
                  id: item.id,
                  name: item.name,
                  quantity: item.quantity - snapshot.quantity.toInt(),
                  buyPrice: item.buyPrice,
                  sellPrice: item.sellPrice,
                  lowStockThreshold: item.lowStockThreshold,
                );
                await provider.updateInventoryItem(updatedItem); // Syncs to Firebase
              }
              await provider.updateInventoryAndSales(
                  widget.selectedDate, widget.selectedTimeSlot);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enregistrement annulé')),
              );
            },
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'enregistrement: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _clearSelectedQuantities() {
    _lastClearedValues.clear();
    _selectedItems.forEach((itemName, isSelected) {
      if (isSelected) {
        final controller = quantityControllers[itemName]!;
        _lastClearedValues.add({
          'itemName': itemName,
          'value': controller.text,
        });
        controller.clear();
      }
    });
    setState(() {
      _selectedItems.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Quantités sélectionnées effacées'),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {
            for (var cleared in _lastClearedValues) {
              quantityControllers[cleared['itemName']!]!.text = cleared['value']!;
            }
            _lastClearedValues.clear();
          },
        ),
      ),
    );
  }

  void _prefillSelectedQuantities(String value) {
    _selectedItems.forEach((itemName, isSelected) {
      if (isSelected) {
        quantityControllers[itemName]!.text = value;
      }
    });
    setState(() {
      _selectedItems.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quantités pré-remplies')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final inventoryItems = provider.inventory;

    for (var item in inventoryItems) {
      if (!quantityControllers.containsKey(item.name)) {
        quantityControllers[item.name] = TextEditingController();
      }
      if (!_selectedItems.containsKey(item.name)) {
        _selectedItems[item.name] = false;
      }
    }
    quantityControllers
        .removeWhere((key, value) => !inventoryItems.any((item) => item.name == key));
    _selectedItems
        .removeWhere((key, value) => !inventoryItems.any((item) => item.name == key));

    final filteredItems = inventoryItems
        .where((item) => item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    filteredItems.sort((a, b) {
      if (_sortBy == 'name') {
        return _sortAscending
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name);
      } else {
        return _sortAscending
            ? a.quantity.compareTo(b.quantity)
            : b.quantity.compareTo(a.quantity);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.inventoryTitle),
        actions: [
          if (_selectedItems.values.any((selected) => selected)) ...[
            IconButton(
              icon: const Icon(FontAwesomeIcons.trash),
              onPressed: _clearSelectedQuantities,
              tooltip: 'Effacer les quantités sélectionnées',
            ),
            IconButton(
              icon: const Icon(FontAwesomeIcons.fill),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Pré-remplir les quantités'),
                    content: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantité',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        _prefillSelectedQuantities(value);
                        Navigator.pop(context);
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          final controller = (context as Element)
                              .findAncestorWidgetOfExactType<AlertDialog>()!
                              .content as TextField;
                          _prefillSelectedQuantities(controller.controller!.text);
                          Navigator.pop(context);
                        },
                        child: const Text('Confirmer'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Pré-remplir les quantités',
            ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${widget.selectedDate}, Session: ${widget.selectedTimeSlot}, Météo: ${widget.selectedWeather}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.searchItems,
                prefixIcon: const Icon(
                  FontAwesomeIcons.search,
                  color: Color(0xFF4A2F1A),
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _sortBy,
                  items: [
                    DropdownMenuItem(
                      value: 'name',
                      child: Text(AppLocalizations.of(context)!.sortByName),
                    ),
                    DropdownMenuItem(
                      value: 'quantity',
                      child: Text(AppLocalizations.of(context)!.sortByQuantity),
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
                    _sortAscending
                        ? FontAwesomeIcons.sortAmountDown
                        : FontAwesomeIcons.sortAmountUp,
                    color: const Color(0xFF4A2F1A),
                  ),
                  onPressed: () {
                    setState(() {
                      _sortAscending = !_sortAscending;
                    });
                  },
                  tooltip: 'Changer l\'ordre de tri',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 16,
                      dataRowHeight: 72,
                      headingRowColor: WidgetStateColor.resolveWith(
                        (states) =>
                            Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                      ),
                      columns: [
                        DataColumn(
                          label: Checkbox(
                            value: filteredItems.isNotEmpty &&
                                filteredItems.every(
                                    (item) => _selectedItems[item.name] == true),
                            onChanged: (value) {
                              setState(() {
                                filteredItems.forEach((item) {
                                  _selectedItems[item.name] = value!;
                                });
                              });
                            },
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Article',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Quantité',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ],
                      rows: filteredItems.map((item) {
                        final controller = quantityControllers[item.name]!;
                        return DataRow(
                          color: WidgetStateColor.resolveWith(
                            (states) => filteredItems.indexOf(item) % 2 == 0
                                ? Colors.white
                                : Theme.of(context).colorScheme.surface,
                          ),
                          cells: [
                            DataCell(
                              Checkbox(
                                value: _selectedItems[item.name]!,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedItems[item.name] = value!;
                                  });
                                },
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.box,
                                    color: item.quantity <= item.lowStockThreshold
                                        ? Colors.red
                                        : const Color(0xFF4A2F1A),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.name,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 120,
                                child: TextFormField(
                                  controller: controller,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'Qté',
                                    prefixIcon: Icon(
                                      FontAwesomeIcons.boxes,
                                      color: Color(0xFF4A2F1A),
                                      size: 20,
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      final num = double.tryParse(value);
                                      if (num == null) return 'Invalide';
                                      if (num < 0) return 'Doit être >= 0';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : () => _saveAndSubmit(context, provider),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Enregistrer et soumettre'),
            ),
          ],
        ),
      ),
    );
  }
}