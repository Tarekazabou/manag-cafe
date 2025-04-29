// File: lib/screens/deliveries_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/app_provider.dart';

class DeliveriesScreen extends StatefulWidget {
  const DeliveriesScreen({super.key});

  @override
  _DeliveriesScreenState createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends State<DeliveriesScreen> {
  Map<String, TextEditingController> quantityControllers = {};
  Map<String, TextEditingController> costControllers = {};
  bool _isSaving = false;
  List<Map<String, dynamic>> _lastSavedDeliveries = [];

  @override
  void dispose() {
    quantityControllers.values.forEach((controller) => controller.dispose());
    costControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _saveDeliveries(BuildContext context, AppProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer l\'enregistrement'),
        content: const Text('Voulez-vous enregistrer ces livraisons ?'),
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
      _lastSavedDeliveries.clear();
      for (var item in provider.inventory) {
        final quantityText = quantityControllers[item.name]?.text ?? '';
        final costText = costControllers[item.name]?.text ?? '';

        if (quantityText.isNotEmpty && costText.isNotEmpty) {
          final deliveredQuantity = double.parse(quantityText);
          final totalCost = double.parse(costText);

          if (deliveredQuantity < 0 || totalCost < 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('La quantité livrée et le coût doivent être positifs'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _isSaving = false;
            });
            return;
          }

          if (deliveredQuantity > 0) {
            await provider.recordDelivery(item.id, deliveredQuantity, totalCost);
            _lastSavedDeliveries.add({
              'itemId': item.id,
              'deliveredQuantity': deliveredQuantity,
              'totalCost': totalCost,
              'itemName': item.name,
            });
            hasValidInput = true;
          }
        }
      }

      if (!hasValidInput) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucune livraison valide à enregistrer'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Livraisons enregistrées avec succès'),
          action: SnackBarAction(
            label: 'Annuler',
            onPressed: () async {
              for (var delivery in _lastSavedDeliveries) {
                final itemId = delivery['itemId'] as String;
                final deliveredQuantity = delivery['deliveredQuantity'] as double;
                final totalCost = delivery['totalCost'] as double;
                // Undo by recording a negative delivery to revert the quantity and cost
                await provider.recordDelivery(itemId, -deliveredQuantity, -totalCost);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Livraisons annulées')),
              );
            },
          ),
        ),
      );

      quantityControllers.forEach((key, controller) => controller.clear());
      costControllers.forEach((key, controller) => controller.clear());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Échec de l\'enregistrement des livraisons: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final inventoryItems = provider.inventory;

    for (var item in inventoryItems) {
      quantityControllers[item.name] ??= TextEditingController();
      costControllers[item.name] ??= TextEditingController();
    }
    quantityControllers
        .removeWhere((key, value) => !inventoryItems.any((item) => item.name == key));
    costControllers
        .removeWhere((key, value) => !inventoryItems.any((item) => item.name == key));

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enregistrer les livraisons',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16,
                    dataRowHeight: 72,
                    headingRowColor: WidgetStateColor.resolveWith(
                      (states) => Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                    ),
                    columns: [
                      DataColumn(
                        label: Text(
                          'Article',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Qté livrée',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Coût total',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                    ],
                    rows: inventoryItems.map((item) {
                      return DataRow(
                        color: WidgetStateColor.resolveWith(
                          (states) => inventoryItems.indexOf(item) % 2 == 0
                              ? Colors.white
                              : Theme.of(context).colorScheme.surface,
                        ),
                        cells: [
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
                                controller: quantityControllers[item.name],
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
                          DataCell(
                            SizedBox(
                              width: 120,
                              child: TextFormField(
                                controller: costControllers[item.name],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'Coût',
                                  prefixIcon: Icon(
                                    FontAwesomeIcons.dollarSign,
                                    color: Color(0xFF4A2F1A),
                                    size: 20,
                                  ),
                                  border: OutlineInputBorder(),
                                  suffixText: '€',
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
            onPressed: _isSaving ? null : () => _saveDeliveries(context, provider),
            child: _isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Enregistrer les livraisons'),
          ),
        ],
      ),
    );
  }
}