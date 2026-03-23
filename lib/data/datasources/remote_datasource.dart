import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/inventory_snapshot.dart';

class RemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Inventory operations
  Future<List<InventoryItem>> getInventoryItems(String shopId) async {
    try {
      final snapshot = await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('inventory')
          .get();
      return snapshot.docs
          .map((doc) => InventoryItem.fromJson(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<InventoryItem?> getInventoryItem(String shopId, String itemId) async {
    try {
      final doc = await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('inventory')
          .doc(itemId)
          .get();
      return doc.exists ? InventoryItem.fromJson(doc.data()!) : null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveInventoryItem(String shopId, InventoryItem item) async {
    try {
      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('inventory')
          .doc(item.id)
          .set(item.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteInventoryItem(String shopId, String itemId) async {
    try {
      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('inventory')
          .doc(itemId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<InventoryItem>> getInventoryStream(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('inventory')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryItem.fromJson(doc.data()))
            .toList());
  }

  // Sales operations
  Future<List<Sale>> getSales(String shopId) async {
    try {
      final snapshot = await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('sales')
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Sale.fromJson(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveSale(String shopId, Sale sale) async {
    try {
      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('sales')
          .doc(sale.id)
          .set(sale.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSale(String shopId, String saleId) async {
    try {
      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('sales')
          .doc(saleId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Sale>> getSalesStream(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('sales')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Sale.fromJson(doc.data())).toList());
  }

  // Snapshots operations
  Future<List<InventorySnapshot>> getSnapshots(String shopId) async {
    try {
      final snapshot = await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('snapshots')
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => InventorySnapshot.fromJson(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveSnapshot(String shopId, InventorySnapshot snapshot) async {
    try {
      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('snapshots')
          .doc(snapshot.id)
          .set(snapshot.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<InventorySnapshot>> getSnapshotsStream(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('snapshots')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventorySnapshot.fromJson(doc.data()))
            .toList());
  }
}
