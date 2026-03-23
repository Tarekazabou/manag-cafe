import '../entities/inventory_item.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getInventoryItems(String shopId);
  Future<InventoryItem?> getItem(String shopId, String itemId);
  Future<void> addItem(String shopId, InventoryItem item);
  Future<void> updateItem(String shopId, InventoryItem item);
  Future<void> deleteItem(String shopId, String itemId);
}
