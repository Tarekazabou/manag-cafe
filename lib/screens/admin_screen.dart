import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animations/animations.dart';
import '../models/inventory_item.dart';
import '../providers/app_provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isAuthenticated = false;
  final TextEditingController _passcodeController = TextEditingController();
  final String _adminPasscode = 'tarek';
  int _selectedIndex = 0;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final buyPriceController = TextEditingController();
  final sellPriceController = TextEditingController();
  final thresholdController = TextEditingController();
  bool _isAdding = false;
  bool _isSellable = true; // New field for the add item form

  void _authenticate() {
    if (_passcodeController.text == _adminPasscode) {
      setState(() {
        _isAuthenticated = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code incorrect'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void showEditDialog(BuildContext context, InventoryItem item, AppProvider provider) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: item.name);
    final quantityController = TextEditingController(text: item.quantity.toString());
    final buyPriceController = TextEditingController(text: item.buyPrice.toString());
    final sellPriceController = TextEditingController(text: item.sellPrice.toString());
    final thresholdController =
        TextEditingController(text: item.lowStockThreshold.toString());
    bool isUpdating = false;
    bool isSellable = item.isSellable; // New field for editing

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
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Requis';
                      if (double.tryParse(value) == null) return 'Nombre invalide';
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
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Requis';
                      if (double.tryParse(value) == null) return 'Nombre invalide';
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
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Requis';
                      if (double.tryParse(value) == null) return 'Nombre invalide';
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
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Requis';
                      if (double.tryParse(value) == null) return 'Nombre invalide';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Article vendable directement ?'),
                      const SizedBox(width: 8),
                      Switch(
                        value: isSellable,
                        onChanged: (value) {
                          setState(() {
                            isSellable = value;
                          });
                        },
                      ),
                    ],
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
                          isSellable: isSellable, // Include the new field
                        );
                        try {
                          await provider.updateInventoryItem(updatedItem);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${updatedItem.name} modifié avec succès'),
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
  void dispose() {
    _passcodeController.dispose();
    nameController.dispose();
    quantityController.dispose();
    buyPriceController.dispose();
    sellPriceController.dispose();
    thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Entrez le code administrateur',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _passcodeController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Code',
                        prefixIcon: Icon(
                          FontAwesomeIcons.lock,
                          color: Color(0xFF4A2F1A),
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _authenticate,
                      child: const Text('Valider'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final provider = Provider.of<AppProvider>(context);
    final List<Widget> _adminScreens = [
      // Tab 1: Add Item
      Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin - Ajouter un article',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                          ),
                          validator: (value) =>
                              (value == null || value.isEmpty) ? 'Requis' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantité initiale',
                            prefixIcon: Icon(
                              FontAwesomeIcons.boxes,
                              color: Color(0xFF4A2F1A),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Requis';
                            if (double.tryParse(value) == null) return 'Nombre invalide';
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
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Requis';
                            if (double.tryParse(value) == null) return 'Nombre invalide';
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
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Requis';
                            if (double.tryParse(value) == null) return 'Nombre invalide';
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
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Requis';
                            if (double.tryParse(value) == null) return 'Nombre invalide';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text('Article vendable directement ?'),
                            const SizedBox(width: 8),
                            Switch(
                              value: _isSellable,
                              onChanged: (value) {
                                setState(() {
                                  _isSellable = value;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isAdding
                              ? null
                              : () async {
                                  if (formKey.currentState!.validate()) {
                                    setState(() {
                                      _isAdding = true;
                                    });
                                    final item = InventoryItem(
                                      id: const Uuid().v4(),
                                      name: nameController.text,
                                      quantity: double.parse(quantityController.text),
                                      buyPrice: double.parse(buyPriceController.text),
                                      sellPrice: double.parse(sellPriceController.text),
                                      lowStockThreshold:
                                          double.parse(thresholdController.text),
                                      isSellable: _isSellable, // Include the new field
                                    );
                                    try {
                                      final success = await provider.addInventoryItem(item);
                                      if (success) {
                                        nameController.clear();
                                        quantityController.clear();
                                        buyPriceController.clear();
                                        sellPriceController.clear();
                                        thresholdController.clear();
                                        setState(() {
                                          _isSellable = true; // Reset to default
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content:
                                                Text('${item.name} ajouté avec succès'),
                                            action: SnackBarAction(
                                              label: 'Annuler',
                                              onPressed: () {
                                                provider.deleteInventoryItem(item.id);
                                              },
                                            ),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Échec de l\'ajout. Consultez les logs pour plus de détails.'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Erreur lors de l\'ajout: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    } finally {
                                      setState(() {
                                        _isAdding = false;
                                      });
                                    }
                                  }
                                },
                          child: _isAdding
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Ajouter l\'article'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Tab 2: Manage Items (Edit/Delete)
      Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin - Gérer les articles',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, child) {
                  if (provider.inventory.isEmpty) {
                    return Card(
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
                    );
                  }
                  return ListView.builder(
                    itemCount: provider.inventory.length,
                    itemBuilder: (context, index) {
                      final item = provider.inventory[index];
                      return OpenContainer(
                        transitionType: ContainerTransitionType.fadeThrough,
                        transitionDuration: const Duration(milliseconds: 300),
                        closedElevation: 2,
                        closedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        closedColor: Colors.white,
                        openColor: Theme.of(context).scaffoldBackgroundColor,
                        closedBuilder: (context, openContainer) => Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Icon(
                              FontAwesomeIcons.box,
                              color: item.quantity <= item.lowStockThreshold
                                  ? Colors.red
                                  : const Color(0xFF4A2F1A),
                            ),
                            title: Text(
                              item.name,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Quantité: ${item.quantity}',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Text(
                                        'Vendable: ',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      Switch(
                                        value: item.isSellable,
                                        onChanged: (value) async {
                                          try {
                                            await provider.toggleSellableStatus(item.id, value);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    '${item.name} marqué comme ${value ? "vendable" : "non vendable"}'),
                                              ),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Erreur lors de la mise à jour: $e'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
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
                                  onPressed: () => showEditDialog(context, item, provider),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    FontAwesomeIcons.trash,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirmer la suppression'),
                                        content: Text(
                                            'Voulez-vous vraiment supprimer ${item.name} ?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Annuler'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Supprimer'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      try {
                                        await provider.deleteInventoryItem(item.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content:
                                                Text('${item.name} supprimé avec succès'),
                                            action: SnackBarAction(
                                              label: 'Annuler',
                                              onPressed: () {
                                                provider.addInventoryItem(item);
                                              },
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content:
                                                Text('Erreur lors de la suppression: $e'),
                                            backgroundColor: Colors.red,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Détails de l\'article',
                                  style: Theme.of(context).textTheme.headlineLarge,
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
                                  FontAwesomeIcons.exclamationTriangle,
                                ),
                                const SizedBox(height: 16),
                                _buildDetailRow(
                                  context,
                                  'Vendable directement',
                                  item.isSellable ? 'Oui' : 'Non',
                                  FontAwesomeIcons.checkCircle,
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
    ];

    return Scaffold(
      body: _adminScreens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.plus),
            label: 'Ajouter un article',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.edit),
            label: 'Gérer les articles',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF4A2F1A),
        onTap: _onNavTapped,
        type: BottomNavigationBarType.fixed,
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