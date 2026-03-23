import '../../domain/entities/inventory_snapshot.dart';
import '../../domain/repositories/snapshot_repository.dart';
import '../datasources/local_datasource.dart';
import '../datasources/remote_datasource.dart';
import './connectivity_service.dart';
import '../../core/services/retry_service.dart';

class SnapshotRepositoryImpl implements SnapshotRepository {
  final RemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;
  final ConnectivityService _connectivity;

  SnapshotRepositoryImpl({
    required RemoteDataSource remoteDataSource,
    required LocalDataSource localDataSource,
    required ConnectivityService connectivity,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _connectivity = connectivity;

  @override
  Future<List<InventorySnapshot>> getSnapshots(String shopId) async {
    try {
      if (_connectivity.isConnected) {
        final remoteSnapshots =
            await _remoteDataSource.getSnapshots(shopId);
        await _localDataSource.cacheSnapshots(remoteSnapshots);
        return remoteSnapshots;
      }
    } catch (e) {
      // Fallback to local
    }
    return await _localDataSource.getSnapshots();
  }

  @override
  Future<void> addSnapshot(
      String shopId, InventorySnapshot snapshot) async {
    await _localDataSource.saveSnapshot(snapshot);

    if (_connectivity.isConnected) {
      try {
        await RetryService.retry(
          action: () =>
              _remoteDataSource.saveSnapshot(shopId, snapshot),
          operationName: 'Add inventory snapshot',
        );
      } catch (e) {
        rethrow;
      }
    }
  }
}
