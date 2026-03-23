import 'package:sqflite/sqflite.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/inventory_snapshot.dart';
import '../../domain/entities/value_objects.dart';
import '../../services/database_helper.dart';

class LocalDataSource {
  final DatabaseHelper _dbHelper;

  LocalDataSource({required DatabaseHelper dbHelper}) : _dbHelper = dbHelper;

  // Inventory operations
  Future<List<InventoryItem>> getInventoryItems() async {
    return await _dbHelper.getInventoryItems();
  }

  Future<InventoryItem?> getInventoryItem(String itemId) async {
    final items = await _dbHelper.getInventoryItems();
    try {
      return items.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  Future<void> cacheInventoryItems(List<InventoryItem> items) async {
    // Clear and re-insert
    final db = await _dbHelper.database;
    await db.delete('inventory_items');
    for (final item in items) {
      await _dbHelper.insertInventoryItem(item);
    }
  }

  Future<void> saveInventoryItem(InventoryItem item) async {
    await _dbHelper.insertInventoryItem(item);
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    await _dbHelper.updateInventoryItem(item);
  }

  Future<void> deleteInventoryItem(String itemId) async {
    await _dbHelper.deleteInventoryItem(itemId);
  }

  // Sales operations
  Future<List<Sale>> getSales() async {
    return await _dbHelper.getSales();
  }

  Future<Sale?> getSale(String saleId) async {
    final sales = await _dbHelper.getSales();
    try {
      return sales.firstWhere((sale) => sale.id == saleId);
    } catch (e) {
      return null;
    }
  }

  Future<void> cacheSales(List<Sale> sales) async {
    final db = await _dbHelper.database;
    await db.delete('sales');
    for (final sale in sales) {
      await _dbHelper.insertSale(sale);
    }
  }

  Future<void> saveSale(Sale sale) async {
    await _dbHelper.insertSale(sale);
  }

  Future<void> deleteSale(String saleId) async {
    await _dbHelper.deleteSale(saleId);
  }

  // Snapshots operations
  Future<List<InventorySnapshot>> getSnapshots() async {
    return await _dbHelper.getSnapshots();
  }

  Future<void> cacheSnapshots(List<InventorySnapshot> snapshots) async {
    final db = await _dbHelper.database;
    await db.delete('snapshots');
    for (final snapshot in snapshots) {
      await _dbHelper.insertSnapshot(snapshot);
    }
  }

  Future<void> saveSnapshot(InventorySnapshot snapshot) async {
    await _dbHelper.insertSnapshot(snapshot);
  }

  // Sync queue operations
  Future<void> enqueueSyncOperation(SyncOperation operation) async {
    final db = await _dbHelper.database;
    await db.insert('sync_queue', {
      'id': operation.id,
      'entityId': operation.entityId,
      'type': operation.type.name,
      'collection': operation.collection,
      'data': operation.data.toString(),
      'createdAt': operation.createdAt.toIso8601String(),
      'syncedAt': operation.syncedAt?.toIso8601String(),
      'retryCount': operation.retryCount,
      'error': operation.error,
    });
  }

  Future<List<SyncOperation>> getPendingSyncOperations() async {
    final db = await _dbHelper.database;
    final maps = await db
        .query('sync_queue', where: 'syncedAt IS NULL');
    return maps.map((map) {
      return SyncOperation(
        id: map['id'] as String,
        entityId: map['entityId'] as String,
        type: SyncOperationType.values
            .byName(map['type'] as String),
        collection: map['collection'] as String,
        data: {},
        createdAt: DateTime.parse(map['createdAt'] as String),
        syncedAt:
            map['syncedAt'] != null
                ? DateTime.parse(map['syncedAt'] as String)
                : null,
        retryCount: map['retryCount'] as int? ?? 0,
        error: map['error'] as String?,
      );
    }).toList();
  }

  Future<void> markSyncOperationAsComplete(String opId) async {
    final db = await _dbHelper.database;
    await db.update(
      'sync_queue',
      {'syncedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [opId],
    );
  }

  Future<void> incrementRetryCount(String opId) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE sync_queue SET retryCount = retryCount + 1 WHERE id = ?',
      [opId],
    );
  }

  Future<void> markSyncOperationFailed(String opId, String errorMsg) async {
    final db = await _dbHelper.database;
    await db.update(
      'sync_queue',
      {'error': errorMsg},
      where: 'id = ?',
      whereArgs: [opId],
    );
  }
}
