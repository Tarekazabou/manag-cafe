import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shop_manager/domain/entities/inventory_item.dart';
import 'package:coffee_shop_manager/domain/entities/sale.dart';
import 'package:coffee_shop_manager/domain/entities/inventory_snapshot.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isEmployee(String shopId, String userId) async {
    try {
      final userDoc = await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('users')
          .doc(userId)
          .get();
      return userDoc.exists && userDoc.data()!['status'] == 'accepted';
    } catch (e) {
      print('Error checking employee status for shopId: $shopId: $e');
      return false;
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
      throw Exception('Error saving inventory item for shopId: $shopId: $e');
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
      throw Exception('Error saving sale for shopId: $shopId: $e');
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
      throw Exception('Error deleting sale for shopId: $shopId: $e');
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
      throw Exception('Error saving snapshot for shopId: $shopId: $e');
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

  Stream<List<Sale>> getSalesStream(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('sales')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Sale.fromJson(doc.data())).toList());
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

  Stream<Map<String, dynamic>> getPendingRequests(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('joinRequests')
        .snapshots()
        .map((snapshot) {
      final requests = <String, dynamic>{};
      for (var doc in snapshot.docs) {
        requests[doc.id] = doc.data();
      }
      return requests;
    });
  }
}
