import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animations/animations.dart';
import '../providers/app_provider.dart';
import 'admin_screen.dart'; // For navigating to restock

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading data (replace with actual async loading if needed)
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final shopId = provider.shopId;
    final lowStockItems = provider.lowStockItems;

    if (shopId == null) {
      return const Center(child: Text('Shop ID not available'));
    }

    final snapshots = provider.snapshots.where((snapshot) {
      final item = provider.itemMap[snapshot.itemId];
      if (item == null) return false;
      final searchLower = _searchQuery.toLowerCase();
      return item.name.toLowerCase().contains(searchLower) ||
          snapshot.timestamp.toLowerCase().contains(searchLower) ||
          snapshot.timeSlot.toLowerCase().contains(searchLower) ||
          snapshot.weather.toLowerCase().contains(searchLower);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tableau de bord (Shop ID: $shopId)', // Display shopId in the title
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildSummaryRow(
                        context,
                        'Chiffre d\'affaires total',
                        '${provider.totalRevenue.toStringAsFixed(2)} €',
                        FontAwesomeIcons.chartLine,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                        context,
                        'Coût total',
                        '${provider.totalCost.toStringAsFixed(2)} €',
                        FontAwesomeIcons.dollarSign,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                        context,
                        'Profit',
                        '${provider.profit.toStringAsFixed(2)} €',
                        FontAwesomeIcons.moneyBillWave,
                        textColor: provider.profit >= 0 ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (lowStockItems.isNotEmpty) ...[
                Text(
                  'Alertes de stock bas',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                ...lowStockItems.map((item) => Card(
                      color: Colors.red[100],
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(
                          FontAwesomeIcons.exclamationTriangle,
                          color: Colors.red,
                        ),
                        title: Text(
                          item.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        subtitle: Text(
                          'Quantité: ${item.quantity} (Seuil: ${item.lowStockThreshold})',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A2F1A),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Réapprovisionner'),
                        ),
                      ),
                    )),
                const SizedBox(height: 24),
              ],
              Text(
                'Vérifications d\'inventaire',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Rechercher par article, date, session ou météo',
                  prefixIcon: Icon(
                    FontAwesomeIcons.search,
                    color: Color(0xFF4A2F1A),
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              snapshots.isEmpty
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
                                'Aucune vérification d\'inventaire trouvée.',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshots.length,
                      itemBuilder: (context, index) {
                        final snapshot = snapshots[index];
                        final item = provider.itemMap[snapshot.itemId]!;
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
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Icon(
                                FontAwesomeIcons.box,
                                color: const Color(0xFF4A2F1A),
                              ),
                              title: Text(
                                '${item.name} - Qté: ${snapshot.quantity}',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              subtitle: Text(
                                'Date: ${snapshot.timestamp}, Session: ${snapshot.timeSlot}, Météo: ${snapshot.weather}',
                                style: Theme.of(context).textTheme.bodyLarge,
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
                                    'Détails de la vérification',
                                    style: Theme.of(context).textTheme.headlineLarge,
                                  ),
                                  const SizedBox(height: 24),
                                  _buildDetailRow(
                                    context,
                                    'Article',
                                    item.name,
                                    FontAwesomeIcons.tag,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDetailRow(
                                    context,
                                    'Quantité',
                                    snapshot.quantity.toString(),
                                    FontAwesomeIcons.boxes,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDetailRow(
                                    context,
                                    'Date et heure',
                                    snapshot.timestamp,
                                    FontAwesomeIcons.calendar,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDetailRow(
                                    context,
                                    'Session',
                                    snapshot.timeSlot,
                                    FontAwesomeIcons.clock,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDetailRow(
                                    context,
                                    'Météo',
                                    snapshot.weather,
                                    FontAwesomeIcons.cloudSun,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? textColor,
  }) {
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
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ),
      ],
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