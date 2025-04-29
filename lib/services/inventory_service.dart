import 'package:firebase_database/firebase_database.dart';
import '../models/inventory_item.dart';
import '../models/sale.dart';
import '../models/inventory_snapshot.dart';

class InventoryService {
  final String shopId;
  final DatabaseReference _dbRef;

  InventoryService(this.shopId)
      : _dbRef = FirebaseDatabase.instance.ref('shops/$shopId');

  // Inventory Items
  Stream<List<InventoryItem>> getInventoryStream() {
    return _dbRef.child('inventory').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      return data.entries.map((entry) {
        final item = entry.value as Map<dynamic, dynamic>;
        return InventoryItem(
          id: entry.key as String,
          name: item['name'] as String,
          quantity: (item['quantity'] as num).toDouble(),
          buyPrice: (item['buyPrice'] as num).toDouble(),
          sellPrice: (item['sellPrice'] as num).toDouble(),
          lowStockThreshold: (item['lowStockThreshold'] as num).toDouble(),
        );
      }).toList();
    });
  }

  Stream<List<InventoryItem>> getLowStockStream() {
    return getInventoryStream().map((items) => items
        .where((item) => item.quantity <= item.lowStockThreshold)
        .toList());
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    await _dbRef.child('inventory/${item.id}').set(item.toJson());
  }

  Future<void> deleteInventoryItem(String id) async {
    await _dbRef.child('inventory/$id').remove();
  }

  // Sales
  Stream<List<Sale>> getSalesStream() {
    return _dbRef.child('sales').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      return data.entries.map((entry) {
        final sale = entry.value as Map<dynamic, dynamic>;
        return Sale(
          id: entry.key as String,
          itemName: sale['itemName'] as String,
          quantity: (sale['quantity'] as num).toInt(),
          sellingPrice: (sale['sellingPrice'] as num).toDouble(),
          date: sale['date'] as String,
        );
      }).toList();
    });
  }

  Future<void> addSale(Sale sale) async {
    await _dbRef.child('sales/${sale.id}').set(sale.toJson());
  }

  Future<void> deleteSale(String id) async {
    await _dbRef.child('sales/$id').remove();
  }

  // Snapshots
  Stream<List<InventorySnapshot>> getSnapshotsStream() {
    return _dbRef.child('snapshots').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      return data.entries.map((entry) {
        final snapshot = entry.value as Map<dynamic, dynamic>;
        return InventorySnapshot.fromJson({
          'id': entry.key,
          ...snapshot,
        });
      }).toList();
    });
  }

  Future<void> addSnapshot(InventorySnapshot snapshot) async {
    await _dbRef.child('snapshots/${snapshot.id}').set(snapshot.toJson());
  }
}