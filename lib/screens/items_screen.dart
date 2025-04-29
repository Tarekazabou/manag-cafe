import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animations/animations.dart';
import '../models/inventory_item.dart';
import '../providers/app_provider.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  _ItemsScreenState createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  String _searchQuery = '';

  void showEditDialog(
      BuildContext context, InventoryItem item, AppProvider provider) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: item.name);
    final quantityController =
        TextEditingController(text: item.quantity.toString());
    final buyPriceController =
        TextEditingController(text: item.buyPrice.toString());
    final sellPriceController =
        TextEditingController(text: item.sellPrice.toString());
    final thresholdController =
        TextEditingController(text: item.lowStockThreshold.toString());
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Modifier l\'article'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de l\'article',
                      prefixIcon: Icon(
                        FontAwesomeIcons.tag,
                        color: Color(0xFF4A2F1A),
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantité',
                      prefixIcon: Icon(
                        FontAwesomeIcons.boxes,
                        color: Color(0xFF4A2F1A),
                      ),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Requis';
                      final num = double.tryParse(value);
                      if (num == null) return 'Nombre invalide';
                      if (num < 0) return 'Doit être >= 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: buyPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Prix d\'achat',
                      prefixIcon: Icon(
                        FontAwesomeIcons.dollarSign,
                        color: Color(0xFF4A2F1A),
                      ),
                      border: OutlineInputBorder(),
                      suffixText: '€',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Requis';
                      final num = double.tryParse(value);
                      if (num == null) return 'Nombre invalide';
                      if (num < 0) return 'Doit être >= 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: sellPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Prix de vente',
                      prefixIcon: Icon(
                        FontAwesomeIcons.dollarSign,
                        color: Color(0xFF4A2F1A),
                      ),
                      border: OutlineInputBorder(),
                      suffixText: '€',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Requis';
                      final num = double.tryParse(value);
                      if (num == null) return 'Nombre invalide';
                      if (num < 0) return 'Doit être >= 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: thresholdController,
                    decoration: const InputDecoration(
                      labelText: 'Seuil de stock bas',
                      prefixIcon: Icon(
                        FontAwesomeIcons.exclamationTriangle,
                        color: Color(0xFF4A2F1A),
                      ),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Requis';
                      final num = double.tryParse(value);
                      if (num == null) return 'Nombre invalide';
                      if (num < 0) return 'Doit être >= 0';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: isUpdating
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          isUpdating = true;
                        });
                        final updatedItem = InventoryItem(
                          id: item.id,
                          name: nameController.text,
                          quantity: double.parse(quantityController.text),
                          buyPrice: double.parse(buyPriceController.text),
                          sellPrice: double.parse(sellPriceController.text),
                          lowStockThreshold: double.parse(thresholdController.text),
                        );
                        try {
                          await provider.updateInventoryItem(updatedItem);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${updatedItem.name} modifié avec succès'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur lors de la modification: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          setState(() {
                            isUpdating = false;
                          });
                        }
                      }
                    },
              child: isUpdating
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Modifier'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Articles d\'inventaire',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Rechercher un article',
                  prefixIcon: Icon(
                    FontAwesomeIcons.search,
                    color: Color(0xFF4A2F1A),
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: provider.inventory.isEmpty
                    ? Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.infoCircle,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Aucun article dans l\'inventaire.',
                                  style: TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Builder(
                        builder: (context) {
                          final filteredItems = provider.inventory
                              .where((item) => item.name
                                  .toLowerCase()
                                  .contains(_searchQuery))
                              .toList();
                          return filteredItems.isEmpty
                              ? Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.infoCircle,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 12),
                                        const Expanded(
                                          child: Text(
                                            'Aucun article trouvé.',
                                            style: TextStyle(
                                                color: Colors.grey, fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filteredItems.length,
                                  itemBuilder: (context, index) {
                                    final item = filteredItems[index];
                                    return OpenContainer(
                                      transitionType:
                                          ContainerTransitionType.fadeThrough,
                                      transitionDuration:
                                          const Duration(milliseconds: 300),
                                      closedElevation: 2,
                                      closedShape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      closedColor: Colors.white,
                                      openColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      closedBuilder: (context, openContainer) =>
                                          Card(
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.all(16),
                                          leading: Icon(
                                            FontAwesomeIcons.box,
                                            color:
                                                item.quantity <=
                                                        item.lowStockThreshold
                                                    ? Colors.red
                                                    : const Color(0xFF4A2F1A),
                                          ),
                                          title: Text(
                                            item.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium,
                                          ),
                                          subtitle: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Quantité: ${item.quantity}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                                Text(
                                                  'Prix d\'achat: ${item.buyPrice} €',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                                Text(
                                                  'Prix de vente: ${item.sellPrice} €',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                                Text(
                                                  'Seuil de stock bas: ${item.lowStockThreshold}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ],
                                            ),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  FontAwesomeIcons.edit,
                                                  color: Color(0xFF4A2F1A),
                                                ),
                                                onPressed: () =>
                                                    showEditDialog(
                                                        context, item, provider),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  FontAwesomeIcons.trash,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () async {
                                                  final confirm =
                                                      await showDialog<bool>(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                      title: const Text(
                                                          'Confirmer la suppression'),
                                                      content: Text(
                                                          'Voulez-vous vraiment supprimer ${item.name} ?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context, false),
                                                          child: const Text(
                                                              'Annuler'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context, true),
                                                          child: const Text(
                                                              'Supprimer'),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                  if (confirm == true) {
                                                    try {
                                                      await provider
                                                          .deleteInventoryItem(
                                                              item.id);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              '${item.name} supprimé avec succès'),
                                                          action: SnackBarAction(
                                                            label: 'Annuler',
                                                            onPressed: () {
                                                              provider
                                                                  .addInventoryItem(
                                                                      item);
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'Erreur lors de la suppression: $e'),
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                          onTap: openContainer,
                                        ),
                                      ),
                                      openBuilder: (context, _) => Scaffold(
                                        appBar: AppBar(
                                          title: Text(item.name),
                                        ),
                                        body: Padding(
                                          padding: const EdgeInsets.all(24.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Détails de l\'article',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineLarge,
                                              ),
                                              const SizedBox(height: 24),
                                              _buildDetailRow(
                                                context,
                                                'Nom',
                                                item.name,
                                                FontAwesomeIcons.tag,
                                              ),
                                              const SizedBox(height: 16),
                                              _buildDetailRow(
                                                context,
                                                'Quantité',
                                                item.quantity.toString(),
                                                FontAwesomeIcons.boxes,
                                              ),
                                              const SizedBox(height: 16),
                                              _buildDetailRow(
                                                context,
                                                'Prix d\'achat',
                                                '${item.buyPrice} €',
                                                FontAwesomeIcons.dollarSign,
                                              ),
                                              const SizedBox(height: 16),
                                              _buildDetailRow(
                                                context,
                                                'Prix de vente',
                                                '${item.sellPrice} €',
                                                FontAwesomeIcons.dollarSign,
                                              ),
                                              const SizedBox(height: 16),
                                              _buildDetailRow(
                                                context,
                                                'Seuil de stock bas',
                                                item.lowStockThreshold.toString(),
                                                FontAwesomeIcons
                                                    .exclamationTriangle,
                                              ),
                                            ],
                                          ),
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
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$label: $value',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}