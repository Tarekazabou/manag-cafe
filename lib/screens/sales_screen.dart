import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animations/animations.dart';
import '../providers/app_provider.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final shopId = provider.shopId;

    if (shopId == null) {
      return const Center(child: Text('Shop ID not available'));
    }

    final sessionStats = provider.getSessionStats();
    final session1Stats = sessionStats['session1']!;
    final session2Stats = sessionStats['session2']!;

    // Combine stats for display
    Map<String, Map<String, double>> combinedStats = {};
    for (var entry in session1Stats.entries) {
      combinedStats[entry.key] = Map.from(entry.value);
    }
    for (var entry in session2Stats.entries) {
      if (combinedStats.containsKey(entry.key)) {
        combinedStats[entry.key]!['quantitySold'] =
            combinedStats[entry.key]!['quantitySold']! + entry.value['quantitySold']!;
        combinedStats[entry.key]!['totalSpent'] =
            combinedStats[entry.key]!['totalSpent']! + entry.value['totalSpent']!;
        combinedStats[entry.key]!['totalEarned'] =
            combinedStats[entry.key]!['totalEarned']! + entry.value['totalEarned']!;
        combinedStats[entry.key]!['profit'] =
            combinedStats[entry.key]!['profit']! + entry.value['profit']!;
      } else {
        combinedStats[entry.key] = Map.from(entry.value);
      }
    }

    // Calculate totals
    double totalQuantitySold = 0;
    double totalSpent = 0;
    double totalEarned = 0;
    double totalProfit = 0;

    combinedStats.forEach((itemName, stats) {
      totalQuantitySold += stats['quantitySold']!;
      totalSpent += stats['totalSpent']!;
      totalEarned += stats['totalEarned']!;
      totalProfit += stats['profit']!;
    });

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Ventes (Shop ID: $shopId)',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 24),
            // Session 1 Stats
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session 1: Aujourd\'hui 00:00 - 14:00',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    ...session1Stats.entries.map((entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Icon(FontAwesomeIcons.tag, color: Color(0xFF4A2F1A)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${entry.key}: Qté ${entry.value['quantitySold']!.toStringAsFixed(0)}, '
                                  'Dépensé ${entry.value['totalSpent']!.toStringAsFixed(2)} €, '
                                  'Gagné ${entry.value['totalEarned']!.toStringAsFixed(2)} €, '
                                  'Profit ${entry.value['profit']!.toStringAsFixed(2)} €',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Session 2 Stats
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session 2: Aujourd\'hui 14:00 - Hier 00:00',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    ...session2Stats.entries.map((entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Icon(FontAwesomeIcons.tag, color: Color(0xFF4A2F1A)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${entry.key}: Qté ${entry.value['quantitySold']!.toStringAsFixed(0)}, '
                                  'Dépensé ${entry.value['totalSpent']!.toStringAsFixed(2)} €, '
                                  'Gagné ${entry.value['totalEarned']!.toStringAsFixed(2)} €, '
                                  'Profit ${entry.value['profit']!.toStringAsFixed(2)} €',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Sales History Section
            Text(
              'Historique des ventes',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Consumer<AppProvider>(
              builder: (context, provider, child) {
                if (provider.sales.isEmpty) {
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
                              'Aucune vente enregistrée.',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.sales.length,
                  itemBuilder: (context, index) {
                    final sale = provider.sales[index];
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
                          leading: const Icon(
                            FontAwesomeIcons.receipt,
                            color: Color(0xFF4A2F1A),
                          ),
                          title: Text(
                            sale.itemName,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Qté: ${sale.quantity}, Prix: ${sale.sellingPrice} €, Date: ${sale.date.substring(0, 10)}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              FontAwesomeIcons.trash,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              provider.deleteSale(sale.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Vente de ${sale.itemName} supprimée'),
                                  action: SnackBarAction(
                                    label: 'Annuler',
                                    onPressed: () {
                                      provider.addSale(sale);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      openBuilder: (context, _) => Scaffold(
                        appBar: AppBar(
                          title: Text(sale.itemName),
                        ),
                        body: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Détails de la vente',
                                style: Theme.of(context).textTheme.headlineLarge,
                              ),
                              const SizedBox(height: 24),
                              _buildDetailRow(
                                context,
                                'Nom de l\'article',
                                sale.itemName,
                                FontAwesomeIcons.tag,
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                context,
                                'Quantité',
                                sale.quantity.toString(),
                                FontAwesomeIcons.cartShopping,
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                context,
                                'Prix de vente',
                                '${sale.sellingPrice} €',
                                FontAwesomeIcons.dollarSign,
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                context,
                                'Date',
                                sale.date.substring(0, 10),
                                FontAwesomeIcons.calendar,
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
            const SizedBox(height: 24),
            // Sales Statistics Section
            Text(
              'Statistiques combinées',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16,
                  dataRowHeight: 56,
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
                        'Qté vendue',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Dépensé',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Gagné',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Profit',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ],
                  rows: [
                    ...combinedStats.entries.map((entry) {
                      final itemName = entry.key;
                      final stats = entry.value;
                      return DataRow(
                        color: WidgetStateColor.resolveWith(
                          (states) => combinedStats.keys.toList().indexOf(itemName) % 2 == 0
                              ? Colors.white
                              : Theme.of(context).colorScheme.surface,
                        ),
                        cells: [
                          DataCell(Text(
                            itemName,
                            style: Theme.of(context).textTheme.bodyLarge,
                          )),
                          DataCell(Text(stats['quantitySold']!.toStringAsFixed(0))),
                          DataCell(Text('${stats['totalSpent']!.toStringAsFixed(2)} €')),
                          DataCell(Text('${stats['totalEarned']!.toStringAsFixed(2)} €')),
                          DataCell(Text('${stats['profit']!.toStringAsFixed(2)} €')),
                        ],
                      );
                    }).toList(),
                    DataRow(
                      color: WidgetStateColor.resolveWith(
                        (states) => Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                      ),
                      cells: [
                        DataCell(Text(
                          'Total',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                        )),
                        DataCell(Text(
                          totalQuantitySold.toStringAsFixed(0),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )),
                        DataCell(Text(
                          '${totalSpent.toStringAsFixed(2)} €',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )),
                        DataCell(Text(
                          '${totalEarned.toStringAsFixed(2)} €',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )),
                        DataCell(Text(
                          '${totalProfit.toStringAsFixed(2)} €',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
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