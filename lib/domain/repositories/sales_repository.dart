import '../entities/sale.dart';

abstract class SalesRepository {
  Future<List<Sale>> getSales(String shopId);
  Future<Sale?> getSale(String shopId, String saleId);
  Future<void> addSale(String shopId, Sale sale);
  Future<void> deleteSale(String shopId, String saleId);
  Future<List<Sale>> getSalesInRange(String shopId, DateRange dateRange);
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});

  bool contains(DateTime date) =>
      date.isAfter(start) && date.isBefore(end.add(const Duration(days: 1)));
}
