import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/local_datasource.dart';
import '../datasources/remote_datasource.dart';
import './connectivity_service.dart';
import '../../core/services/retry_service.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final RemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;
  final ConnectivityService _connectivity;

  InventoryRepositoryImpl({
    required RemoteDataSource remoteDataSource,
    required LocalDataSource localDataSource,
    required ConnectivityService connectivity,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _connectivity = connectivity;

  @override
  Future<List<InventoryItem>> getInventoryItems(String shopId) async {
    try {
      if (_connectivity.isConnected) {
        final remoteItems =
            await _remoteDataSource.getInventoryItems(shopId);
        await _localDataSource.cacheInventoryItems(remoteItems);
        return remoteItems;
      }
    } catch (e) {
      // Fallback to local
    }
    return await _localDataSource.getInventoryItems();
  }

  @override
  Future<InventoryItem?> getItem(String shopId, String itemId) async {
    try {
      if (_connectivity.isConnected) {
        return await _remoteDataSource.getInventoryItem(shopId, itemId);
      }
    } catch (e) {
      // Fallback to local
    }
    return await _localDataSource.getInventoryItem(itemId);
  }

  @override
  Future<void> addItem(String shopId, InventoryItem item) async {
    await _localDataSource.saveInventoryItem(item);

    if (_connectivity.isConnected) {
      try {
        await RetryService.retry(
          action: () =>
              _remoteDataSource.saveInventoryItem(shopId, item),
          operationName: 'Add inventory item',
        );
      } catch (e) {
        // Marked for retry by sync queue
        rethrow;
      }
    }
  }

  @override
  Future<void> updateItem(String shopId, InventoryItem item) async {
    await _localDataSource.updateInventoryItem(item);

    if (_connectivity.isConnected) {
      try {
        await RetryService.retry(
          action: () =>
              _remoteDataSource.saveInventoryItem(shopId, item),
          operationName: 'Update inventory item',
        );
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<void> deleteItem(String shopId, String itemId) async {
    await _localDataSource.deleteInventoryItem(itemId);

    if (_connectivity.isConnected) {
      try {
        await RetryService.retry(
          action: () =>
              _remoteDataSource.deleteInventoryItem(shopId, itemId),
          operationName: 'Delete inventory item',
        );
      } catch (e) {
        rethrow;
      }
    }
  }
}
