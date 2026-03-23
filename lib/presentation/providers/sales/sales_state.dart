import '../../../domain/entities/sale.dart';
class SalesState {
  final List<Sale> sales;
  final bool isLoading;
  final String? error;
  final DateTime? lastSyncTime;

  SalesState({
    this.sales = const [],
    this.isLoading = false,
    this.error,
    this.lastSyncTime,
  });

  SalesState copyWith({
    List<Sale>? sales,
    bool? isLoading,
    String? error,
    DateTime? lastSyncTime,
  }) =>
      SalesState(
        sales: sales ?? this.sales,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      );
}



