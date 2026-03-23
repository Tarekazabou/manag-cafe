import '../entities/sale.dart';
import '../entities/inventory_item.dart';
import '../repositories/sales_repository.dart';
import '../repositories/inventory_repository.dart';
import '../../core/error/app_exception.dart';
import '../../core/utils/uid_generator.dart';
import '../../core/utils/logger.dart';

abstract class NotificationService {
  Future<void> notifyLowStock({
    required String shopId,
    required InventoryItem item,
  });
}

class AddSaleUseCase {
  final SalesRepository _salesRepository;
  final InventoryRepository _inventoryRepository;
  final NotificationService _notificationService;

  AddSaleUseCase({
    required SalesRepository salesRepository,
    required InventoryRepository inventoryRepository,
    required NotificationService notificationService,
  })  : _salesRepository = salesRepository,
        _inventoryRepository = inventoryRepository,
        _notificationService = notificationService;

  /// Add sale and auto-deduct inventory (transactional)
  Future<Sale> call({
    required String shopId,
    required String itemId,
    required int quantity,
    required double sellingPrice,
    required String createdBy,
  }) async {
    // Fetch current inventory
    final item = await _inventoryRepository.getItem(shopId, itemId);

    if (item == null) {
      throw ValidationException(message: 'Item not found');
    }

    // Validate stock
    if (item.quantity < quantity) {
      throw InsufficientStockException(
        itemName: item.name,
        available: item.quantity,
        requested: quantity.toDouble(),
      );
    }

    final cost = item.buyPrice * quantity;
    final totalAmount = sellingPrice * quantity;
    final margin = totalAmount - cost;

    // Create sale
    final sale = Sale(
      id: generateSalesId(),
      itemId: itemId,
      itemName: item.name,
      quantity: quantity,
      sellingPrice: sellingPrice,
      totalAmount: totalAmount,
      cost: cost,
      margin: margin,
      date: DateTime.now(),
      createdBy: createdBy,
    );

    // Deduct inventory
    final updatedItem = item.copyWith(
      quantity: item.quantity - quantity,
      updatedBy: createdBy,
    );

    try {
      // Save sale & update inventory
      await Future.wait([
        _salesRepository.addSale(shopId, sale),
        _inventoryRepository.updateItem(shopId, updatedItem),
      ]);

      logger.info('✅ Sale recorded: ${item.name} x$quantity');

      // Check low stock after deduction
      if (updatedItem.quantity <= updatedItem.lowStockThreshold) {
        await _notificationService.notifyLowStock(
          shopId: shopId,
          item: updatedItem,
        );
      }

      return sale;
    } catch (e) {
      logger.error('❌ Failed to record sale', error: e);
      throw TransactionFailedException('Failed to record sale: $e');
    }
  }
}

