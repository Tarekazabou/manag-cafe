import '../../domain/entities/sale.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/local_datasource.dart';
import '../datasources/remote_datasource.dart';
import './connectivity_service.dart';
import '../../core/services/retry_service.dart';

class SalesRepositoryImpl implements SalesRepository {
  final RemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;
  final ConnectivityService _connectivity;

  SalesRepositoryImpl({
    required RemoteDataSource remoteDataSource,
    required LocalDataSource localDataSource,
    required ConnectivityService connectivity,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _connectivity = connectivity;

  @override
  Future<List<Sale>> getSales(String shopId) async {
    try {
      if (_connectivity.isConnected) {
        final remoteSales = await _remoteDataSource.getSales(shopId);
        await _localDataSource.cacheSales(remoteSales);
        return remoteSales;
      }
    } catch (e) {
      // Fallback to local
    }
    return await _localDataSource.getSales();
  }

  @override
  Future<Sale?> getSale(String shopId, String saleId) async {
    try {
      if (_connectivity.isConnected) {
        return await _remoteDataSource.getSales(shopId).then(
          (sales) => sales.firstWhere(
            (s) => s.id == saleId,
            orElse: () => null as Sale,
          ),
        );
      }
    } catch (e) {
      // Fallback to local
    }
    return await _localDataSource.getSale(saleId);
  }

  @override
  Future<void> addSale(String shopId, Sale sale) async {
    await _localDataSource.saveSale(sale);

    if (_connectivity.isConnected) {
      try {
        await RetryService.retry(
          action: () => _remoteDataSource.saveSale(shopId, sale),
          operationName: 'Add sale',
        );
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<void> deleteSale(String shopId, String saleId) async {
    await _localDataSource.deleteSale(saleId);

    if (_connectivity.isConnected) {
      try {
        await RetryService.retry(
          action: () => _remoteDataSource.deleteSale(shopId, saleId),
          operationName: 'Delete sale',
        );
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<List<Sale>> getSalesInRange(
      String shopId, DateRange dateRange) async {
    final sales = await getSales(shopId);
    return sales
        .where((sale) => dateRange.contains(sale.date))
        .toList();
  }
}
