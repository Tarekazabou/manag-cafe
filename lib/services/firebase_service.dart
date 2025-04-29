import 'package:firebase_database/firebase_database.dart';
import '../models/inventory_item.dart';
import '../models/sale.dart';
import '../models/inventory_snapshot.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Save or update inventory item in Firebase
  Future<void> saveInventoryItem(String shopId, InventoryItem item) async {
    try {
      await _db.child('shops').child(shopId).child('inventory').child(item.id).set(item.toJson());
    } catch (e) {
      print('Error saving inventory item: $e');
      rethrow;
    }
  }

  // Listen for inventory changes in real-time
  Stream<List<InventoryItem>> getInventoryStream(String shopId) {
    return _db.child('shops').child(shopId).child('inventory').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((entry) {
        return InventoryItem.fromJson(Map<String, dynamic>.from(entry.value));
      }).toList();
    });
  }

  // Save or update sale in Firebase
  Future<void> saveSale(String shopId, Sale sale) async {
    try {
      await _db.child('shops').child(shopId).child('sales').child(sale.id).set(sale.toJson());
    } catch (e) {
      print('Error saving sale: $e');
      rethrow;
    }
  }

  // Delete sale from Firebase
  Future<void> deleteSale(String shopId, String saleId) async {
    try {
      await _db.child('shops').child(shopId).child('sales').child(saleId).remove();
    } catch (e) {
      print('Error deleting sale: $e');
      rethrow;
    }
  }

  // Listen for sales changes in real-time
  Stream<List<Sale>> getSalesStream(String shopId) {
    return _db.child('shops').child(shopId).child('sales').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((entry) {
        return Sale.fromJson(Map<String, dynamic>.from(entry.value));
      }).toList();
    });
  }

  // Save or update snapshot in Firebase
  Future<void> saveSnapshot(String shopId, InventorySnapshot snapshot) async {
    try {
      await _db.child('shops').child(shopId).child('snapshots').child(snapshot.id).set(snapshot.toJson());
    } catch (e) {
      print('Error saving snapshot: $e');
      rethrow;
    }
  }

  // Listen for snapshots changes in real-time
  Stream<List<InventorySnapshot>> getSnapshotsStream(String shopId) {
    return _db.child('shops').child(shopId).child('snapshots').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((entry) {
        return InventorySnapshot.fromJson(Map<String, dynamic>.from(entry.value));
      }).toList();
    });
  }

  // Get pending requests for the owner
  Stream<Map<String, dynamic>> getPendingRequests(String shopId) {
    return _db.child('shops').child(shopId).child('requests').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return {};
      return Map<String, dynamic>.from(data);
    });
  }

  // Check if user is an employee of the shop
  Future<bool> isEmployee(String shopId, String userId) async {
    final snapshot = await _db.child('shops').child(shopId).child('employees').child(userId).get();
    return snapshot.exists;
  }
}