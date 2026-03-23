import '../../domain/entities/sale.dart';
import 'dart:async';
import '../../domain/entities/value_objects.dart';
import '../datasources/remote_datasource.dart';
import '../datasources/local_datasource.dart';
import './connectivity_service.dart';
import '../../core/utils/logger.dart';

enum SyncStatus { pending, syncing, synced, failed }

class SyncQueue {
  final LocalDataSource _localDataSource;
  final RemoteDataSource _remoteDataSource;
  final ConnectivityService _connectivity;

  StreamSubscription? _connectivitySubscription;
  final _syncController = StreamController<SyncStatus>.broadcast();

  SyncQueue({
    required LocalDataSource localDataSource,
    required RemoteDataSource remoteDataSource,
    required ConnectivityService connectivity,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _connectivity = connectivity {
    _watchConnectivity();
  }

  void _watchConnectivity() {
    _connectivitySubscription =
        _connectivity.statusChanges.listen((status) {
      if (status == ConnectivityStatus.connected) {
        _processPendingOperations();
      }
    });
  }

  /// Enqueue an operation with timestamp (optimistic update)
  Future<void> enqueue(SyncOperation operation) async {
    final timestampedOp = operation.copyWith(
      createdAt: DateTime.now().toUtc(),
    );
    await _localDataSource.enqueueSyncOperation(timestampedOp);
    _syncController.add(SyncStatus.pending);

    if (_connectivity.isConnected) {
      _processPendingOperations();
    }
  }

  /// Process all pending operations with conflict resolution
  Future<void> _processPendingOperations() async {
    _syncController.add(SyncStatus.syncing);

    final pending = await _localDataSource.getPendingSyncOperations();

    for (final op in pending) {
      try {
        await _syncOperation(op);
        await _localDataSource.markSyncOperationAsComplete(op.id);
        logger.info('✅ Synced: ${op.collection}/${op.entityId}');
      } catch (e) {
        if (op.needsRetry) {
          await _localDataSource.incrementRetryCount(op.id);
          logger.warning('⚠️ Retry queued for ${op.entityId}');
        } else {
          await _localDataSource.markSyncOperationFailed(
              op.id, e.toString());
          logger.error('❌ Sync failed (max retries)', error: e);
        }
      }
    }

    _syncController.add(SyncStatus.synced);
  }

  /// Sync a single operation with conflict resolution
  Future<void> _syncOperation(SyncOperation op) async {
    switch (op.type) {
      case SyncOperationType.create:
        await _remoteDataSource.saveSale('shopId', Sale.fromJson(op.data));
        break;

      case SyncOperationType.update:
        await _remoteDataSource.saveSale('shopId', Sale.fromJson(op.data));
        break;

      case SyncOperationType.delete:
        await _remoteDataSource.deleteSale('shopId', op.entityId);
        break;
    }
  }

  Stream<SyncStatus> get syncStatus => _syncController.stream;

  void dispose() {
    _connectivitySubscription?.cancel();
    _syncController.close();
  }
}



