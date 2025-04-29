import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/app_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).primaryColor,
                  onPrimary: Colors.white,
                  surface: Theme.of(context).colorScheme.surface,
                ),
            dialogTheme: DialogThemeData(
                backgroundColor: Theme.of(context).colorScheme.surface),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final selectedDateStr = _selectedDate.toIso8601String().substring(0, 10);
    final stats = provider.calculateInventoryStats(selectedDateStr);

    // Helper function to safely get stat values
    String getStatValue(Map<String, dynamic>? stat, String key, {bool isDouble = false}) {
      if (stat == null || stat[key] == null || stat[key]! < -9000) {
        return 'N/A';
      }
      return isDouble
          ? (stat[key] as double).toStringAsFixed(2)
          : (stat[key] as double).toStringAsFixed(0);
    }

    // Safely access sugarCubes
    String getSugarCubes() {
      final sugarCubes = stats['sugarCubes'] as double?;
      return sugarCubes != null ? sugarCubes.toStringAsFixed(0) : 'N/A';
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Statistiques d\'inventaire',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 24),
            // Date Picker
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon: const Icon(
                      FontAwesomeIcons.calendar,
                      color: Color(0xFF4A2F1A),
                    ),
                    suffixIcon: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF4A2F1A),
                    ),
                    hintText: selectedDateStr,
                  ),
                  controller: TextEditingController(text: selectedDateStr),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Usage Analysis Section
            Text(
              'Analyse de l\'utilisation',
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
                    (states) =>
                        Theme.of(context).colorScheme.secondary.withOpacity(0.2),
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
                        'Début',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Utilisation prévue',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Utilisation réelle',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Fin',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Écart',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ],
                  rows: [
                    DataRow(
                      color: WidgetStateColor.resolveWith(
                        (states) => Colors.white,
                      ),
                      cells: [
                        DataCell(Text('Gobelets G. 12',
                            style: Theme.of(context).textTheme.bodyLarge)),
                        DataCell(Text(
                            getStatValue(stats['G. 12'] as Map<String, dynamic>?,
                                'starting'))),
                        DataCell(Text(
                            getStatValue(stats['G. 12'] as Map<String, dynamic>?,
                                'expectedUsed'))),
                        DataCell(Text(
                            getStatValue(stats['G. 12'] as Map<String, dynamic>?,
                                'actualUsed'))),
                        DataCell(Text(
                            getStatValue(stats['G. 12'] as Map<String, dynamic>?,
                                'ending'))),
                        DataCell(Text(
                            getStatValue(stats['G. 12'] as Map<String, dynamic>?,
                                'discrepancy'))),
                      ],
                    ),
                    DataRow(
                      color: WidgetStateColor.resolveWith(
                        (states) => Theme.of(context).colorScheme.surface,
                      ),
                      cells: [
                        DataCell(Text('Gobelets G. 25',
                            style: Theme.of(context).textTheme.bodyLarge)),
                        DataCell(Text(
                            getStatValue(stats['G. 25'] as Map<String, dynamic>?,
                                'starting'))),
                        DataCell(Text(
                            getStatValue(stats['G. 25'] as Map<String, dynamic>?,
                                'expectedUsed'))),
                        DataCell(Text(
                            getStatValue(stats['G. 25'] as Map<String, dynamic>?,
                                'actualUsed'))),
                        DataCell(Text(
                            getStatValue(stats['G. 25'] as Map<String, dynamic>?,
                                'ending'))),
                        DataCell(Text(
                            getStatValue(stats['G. 25'] as Map<String, dynamic>?,
                                'discrepancy'))),
                      ],
                    ),
                    DataRow(
                      color: WidgetStateColor.resolveWith(
                        (states) => Colors.white,
                      ),
                      cells: [
                        DataCell(Text('Sucre (kg)',
                            style: Theme.of(context).textTheme.bodyLarge)),
                        DataCell(Text(
                            getStatValue(stats['Sugar'] as Map<String, dynamic>?,
                                'starting',
                                isDouble: true))),
                        DataCell(Text(
                            getStatValue(stats['Sugar'] as Map<String, dynamic>?,
                                'expectedUsed',
                                isDouble: true))),
                        DataCell(Text(
                            getStatValue(stats['Sugar'] as Map<String, dynamic>?,
                                'actualUsed',
                                isDouble: true))),
                        DataCell(Text(
                            getStatValue(stats['Sugar'] as Map<String, dynamic>?,
                                'ending',
                                isDouble: true))),
                        DataCell(Text(
                            getStatValue(stats['Sugar'] as Map<String, dynamic>?,
                                'discrepancy',
                                isDouble: true))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Summary Section
            Text(
              'Résumé',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryRow(
                      context,
                      'Cafés G. 12 vendus',
                      getStatValue(
                          stats['G. 12'] as Map<String, dynamic>?, 'expectedUsed'),
                      FontAwesomeIcons.mugHot,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      context,
                      'Cafés G. 25 vendus',
                      getStatValue(
                          stats['G. 25'] as Map<String, dynamic>?, 'expectedUsed'),
                      FontAwesomeIcons.mugHot,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      context,
                      'Morceaux de sucre utilisés',
                      getSugarCubes(),
                      FontAwesomeIcons.cubes,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      context,
                      'Sucre (kg) attendu',
                      getStatValue(stats['Sugar'] as Map<String, dynamic>?,
                          'expectedUsed',
                          isDouble: true),
                      FontAwesomeIcons.weightHanging,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Potential Issues Section
            Text(
              'Problèmes potentiels',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            if (stats['issues'] == null || stats['issues'].isEmpty)
              Card(
                color: Colors.green.withOpacity(0.1),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.checkCircle,
                        color: Colors.green,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Aucun écart significatif détecté.',
                          style: TextStyle(color: Colors.green, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...stats['issues'].map((issue) => Card(
                    color: Colors.red.withOpacity(0.1),
                    child: ListTile(
                      title: Text(
                        issue,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      leading: const Icon(
                        FontAwesomeIcons.triangleExclamation,
                        color: Colors.red,
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
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