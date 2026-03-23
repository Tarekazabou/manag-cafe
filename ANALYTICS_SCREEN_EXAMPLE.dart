// Example: Complete Analytics Screen Implementation
// Location: lib/presentation/screens/analytics/analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../domain/entities/value_objects.dart';
import '../../../domain/repositories/sales_repository.dart';
import '../../../domain/usecases/calculate_profit_usecase.dart';
import '../../../core/dependency_injection/service_locator.dart';
import '../../../core/error/error_handler.dart';

// State class
class AnalyticsState {
  final ProfitMetrics? metrics;
  final List<DailyRevenue> revenueByDay;
  final List<TopSellingItem> topItems;
  final bool isLoading;
  final String? error;
  final DateTime? calculatedAt;

  AnalyticsState({
    this.metrics,
    this.revenueByDay = const [],
    this.topItems = const [],
    this.isLoading = false,
    this.error,
    this.calculatedAt,
  });

  AnalyticsState copyWith({
    ProfitMetrics? metrics,
    List<DailyRevenue>? revenueByDay,
    List<TopSellingItem>? topItems,
    bool? isLoading,
    String? error,
    DateTime? calculatedAt,
  }) =>
      AnalyticsState(
        metrics: metrics ?? this.metrics,
        revenueByDay: revenueByDay ?? this.revenueByDay,
        topItems: topItems ?? this.topItems,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        calculatedAt: calculatedAt ?? this.calculatedAt,
      );
}

// Provider
class AnalyticsProvider extends ChangeNotifier {
  final CalculateProfitUseCase _calculateProfitUseCase;
  final SalesRepository _salesRepository;
  final String _shopId;

  AnalyticsState _state = AnalyticsState();
  AnalyticsState get state => _state;

  AnalyticsProvider({
    required CalculateProfitUseCase calculateProfitUseCase,
    required SalesRepository salesRepository,
    required String shopId,
  })  : _calculateProfitUseCase = calculateProfitUseCase,
        _salesRepository = salesRepository,
        _shopId = shopId {
    _init();
  }

  Future<void> _init() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    await loadAnalytics(DateRange(start: thirtyDaysAgo, end: DateTime.now()));
  }

  Future<void> loadAnalytics({required DateRange dateRange}) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      // Get metrics
      final metrics = await _calculateProfitUseCase(
        shopId: _shopId,
        dateRange: dateRange,
      );

      // Get sales for visualization
      final sales = await _salesRepository.getSalesInRange(_shopId, dateRange);

      // Calculate revenue by day
      final revenueByDay = _calculateRevenueByDay(sales);

      // Get top selling items
      final topItems = _getTopSellingItems(sales);

      _state = _state.copyWith(
        metrics: metrics,
        revenueByDay: revenueByDay,
        topItems: topItems,
        isLoading: false,
        calculatedAt: DateTime.now(),
      );
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
    notifyListeners();
  }

  List<DailyRevenue> _calculateRevenueByDay(List<Sale> sales) {
    final grouped = <DateTime, double>{};

    for (final sale in sales) {
      final day = DateTime(sale.date.year, sale.date.month, sale.date.day);
      grouped[day] = (grouped[day] ?? 0) + sale.totalAmount;
    }

    return grouped.entries
        .map((e) => DailyRevenue(date: e.key, revenue: e.value))
        .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<TopSellingItem> _getTopSellingItems(List<Sale> sales) {
    final grouped = <String, (int, double)>{};

    for (final sale in sales) {
      final existing = grouped[sale.itemName] ?? (0, 0);
      grouped[sale.itemName] = (
        existing.$1 + sale.quantity,
        existing.$2 + sale.totalAmount,
      );
    }

    return grouped.entries
        .map((e) => TopSellingItem(
          itemName: e.key,
          quantity: e.value.$1,
          revenue: e.value.$2,
        ))
        .toList()
        ..sort((a, b) => b.quantity.compareTo(a.quantity))
        ..take(5);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Value objects
class DailyRevenue {
  final DateTime date;
  final double revenue;

  DailyRevenue({required this.date, required this.revenue});
}

class TopSellingItem {
  final String itemName;
  final int quantity;
  final double revenue;

  TopSellingItem({
    required this.itemName,
    required this.quantity,
    required this.revenue,
  });
}

// Screen
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late DateRange _dateRange;

  @override
  void initState() {
    super.initState();
    _dateRange = DateRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Consumer<AnalyticsProvider>(
        builder: (context, analyticsProvider, _) {
          if (analyticsProvider.state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (analyticsProvider.state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${analyticsProvider.state.error}'),
                  ElevatedButton(
                    onPressed: () =>
                        analyticsProvider.loadAnalytics(dateRange: _dateRange),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final metrics = analyticsProvider.state.metrics;
          if (metrics == null) {
            return const Center(child: Text('No data available'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // KPI Cards
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _KPICard(
                      title: 'Revenue',
                      value:
                          '${metrics.totalRevenue.toStringAsFixed(2)} DZD',
                      icon: Icons.trending_up,
                      color: Colors.green,
                    ),
                    _KPICard(
                      title: 'Profit Margin',
                      value: '${metrics.marginPercent.toStringAsFixed(1)}%',
                      icon: Icons.pie_chart,
                      color: Colors.blue,
                    ),
                    _KPICard(
                      title: 'Items Sold',
                      value: '${metrics.itemsSoldCount}',
                      icon: Icons.shopping_bag,
                      color: Colors.orange,
                    ),
                    _KPICard(
                      title: 'Transactions',
                      value: '${metrics.transactionCount}',
                      icon: Icons.receipt,
                      color: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Revenue chart
                if (analyticsProvider.state.revenueByDay.isNotEmpty)
                  _buildRevenueChart(
                      analyticsProvider.state.revenueByDay),
                const SizedBox(height: 20),

                // Top selling items
                if (analyticsProvider.state.topItems.isNotEmpty)
                  _buildTopSellingChart(analyticsProvider.state.topItems),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRevenueChart(List<DailyRevenue> data) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Trend',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  spots: data
                      .asMap()
                      .entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value.revenue))
                      .toList(),
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSellingChart(List<TopSellingItem> data) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Selling Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...data.map((item) => ListTile(
              title: Text(item.itemName),
              subtitle:
                  Text('Qty: ${item.quantity} | Revenue: ${item.revenue.toStringAsFixed(2)}'),
              trailing: const Icon(Icons.star, color: Colors.orange),
            )),
          ],
        ),
      ),
    );
  }
}

// KPI Card Widget
class _KPICard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KPICard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
