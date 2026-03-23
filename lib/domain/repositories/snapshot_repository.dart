import '../entities/inventory_snapshot.dart';

abstract class SnapshotRepository {
  Future<List<InventorySnapshot>> getSnapshots(String shopId);
  Future<void> addSnapshot(String shopId, InventorySnapshot snapshot);
}
