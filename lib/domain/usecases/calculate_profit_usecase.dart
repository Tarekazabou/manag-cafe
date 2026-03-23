import '../entities/sale.dart';
import '../entities/value_objects.dart';
import '../repositories/sales_repository.dart';

class CalculateProfitUseCase {
  final SalesRepository _salesRepository;

  CalculateProfitUseCase(this._salesRepository);

  /// Calculate KPIs for a date range
  Future<ProfitMetrics> call({
    required String shopId,
    required DateRange dateRange,
  }) async {
    final sales = await _salesRepository.getSalesInRange(shopId, dateRange);

    double totalRevenue = 0;
    double totalCost = 0;
    int totalItemsSold = 0;

    for (final sale in sales) {
      totalRevenue += sale.totalAmount;
      totalCost += sale.cost;
      totalItemsSold += sale.quantity;
    }

    final profit = totalRevenue - totalCost;
    final marginPercent = totalRevenue > 0 ? (profit / totalRevenue) * 100 : 0;

    return ProfitMetrics(
      totalRevenue: totalRevenue,
      totalCost: totalCost,
      totalProfit: profit,
      marginPercent: marginPercent,
      avgTransactionValue:
          sales.isNotEmpty ? totalRevenue / sales.length : 0,
      itemsSoldCount: totalItemsSold,
      transactionCount: sales.length,
    );
  }
}
