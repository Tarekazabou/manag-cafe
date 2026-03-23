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

    final profitAmt = totalRevenue - totalCost;
    final marginPercent = totalRevenue > 0 ? (profitAmt / totalRevenue) * 100 : 0.0;

    return ProfitMetrics(
      totalRevenue: totalRevenue,
      totalCost: totalCost,
      profit: profitAmt,
      marginPercent: marginPercent.toDouble(),
      avgTransactionValue:
          sales.isNotEmpty ? totalRevenue / sales.length : 0.0,
      itemsSoldCount: totalItemsSold,
      calculatedAt: DateTime.now(),
      transactionCount: sales.length,
    );
  }
}

