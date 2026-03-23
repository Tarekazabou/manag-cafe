# ⚡ Quick Reference Card

## Before You Start
```bash
flutter pub get  # Install get_it package
flutter pub outdated  # Check for updates
```

---

## File Locations Cheat Sheet

| Feature | File |
|---------|------|
| Exceptions | `core/error/app_exception.dart` |
| Error Display | `core/error/error_handler.dart` |
| Constants | `core/constants/app_constants.dart` |
| Logging | `core/utils/logger.dart` |
| IDs | `core/utils/uid_generator.dart` |
| Retries | `core/services/retry_service.dart` |
| Dependency Injection | `core/dependency_injection/service_locator.dart` |
| Inventory Entity | `domain/entities/inventory_item.dart` |
| Sale Entity | `domain/entities/sale.dart` |
| Profit Metrics | `domain/entities/value_objects.dart` |
| Add Sale Logic | `domain/usecases/add_sale_usecase.dart` |
| Profit Calculation | `domain/usecases/calculate_profit_usecase.dart` |
| Network Check | `data/services/connectivity_service.dart` |
| Sync Manager | `data/services/sync_queue.dart` |
| Inventory Provider | `presentation/providers/inventory/inventory_provider.dart` |
| Sales Provider | `presentation/providers/sales/sales_provider.dart` |

---

## Common Code Patterns

### Access Inventory Items
```dart
Consumer<InventoryProvider>(
  builder: (context, inventoryProvider, _) {
    return ListView(
      children: inventoryProvider.state.items
          .map((item) => ItemTile(item))
          .toList(),
    );
  },
);
```

### Record a Sale (Transactional)
```dart
try {
  await salesProvider.recordSale(
    itemId: 'item-123',
    quantity: 5,
    sellingPrice: 100,
    createdBy: userId,
  );
  // ✅ Auto inventory deducted
  // ✅ Profit calculated
} on InsufficientStockException catch (e) {
  ErrorHandler.showErrorSnackBar(context, e);
}
```

### Show Loading & Error
```dart
Consumer<InventoryProvider>(
  builder: (context, provider, _) {
    if (provider.state.isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (provider.state.error != null) {
      return ErrorWidget(
        error: provider.state.error!,
        onRetry: () => provider.loadInventory(),
      );
    }
    
    return ItemsList(items: provider.state.items);
  },
);
```

### Use a Use Case
```dart
final metricsUseCase = getIt<CalculateProfitUseCase>();
final metrics = await metricsUseCase(
  shopId: 'shop-123',
  dateRange: DateRange(
    start: DateTime(2026, 3, 1),
    end: DateTime(2026, 3, 23),
  ),
);
print('Profit: ${metrics.profit}');
print('Margin: ${metrics.marginPercent}%');
```

### Handle Offline Operations
```dart
final connectivityService = getIt<ConnectivityService>();

connectivityService.statusChanges.listen((status) {
  if (status == ConnectivityStatus.connected) {
    print('🌐 Back online - syncing...');
  } else {
    print('📵 Offline - changes queued');
  }
});
```

---

## Error Types You Can Catch

```dart
try {
  // Some operation
} on InsufficientStockException catch (e) {
  // Item out of stock
  print('${e.itemName}: Only ${e.available} available');
} on ValidationException catch (e) {
  // Invalid input
  print('Invalid input: ${e.message}');
} on PermissionException catch (e) {
  // User not authorized
  print('Permission denied: ${e.message}');
} on NetworkException catch (e) {
  // Network issues
  print('Network error: ${e.message}');
} on TimeoutException catch (e) {
  // Operation took too long
  print('Operation timed out');
} on TransactionFailedException catch (e) {
  // Sale recording failed
  print('Transaction failed: ${e.message}');
} catch (e) {
  // Unknown error
  ErrorHandler.showErrorSnackBar(context, e);
}
```

---

## State Management Quick Reference

### InventoryProvider
```dart
inventoryProvider.state.items        // Get items
inventoryProvider.state.isLoading    // Is loading?
inventoryProvider.state.error        // Current error
inventoryProvider.state.lastSyncTime // Last sync

inventoryProvider.loadInventory()    // Refresh
inventoryProvider.addItem(item)      // Add item
inventoryProvider.updateItem(item)   // Update item
inventoryProvider.deleteItem(id)     // Delete item
```

### SalesProvider
```dart
salesProvider.state.sales           // Get sales
salesProvider.state.isLoading       // Is loading?
salesProvider.state.error           // Current error

salesProvider.loadSales()           // Refresh
salesProvider.recordSale(...)       // Record sale (transactional!)
salesProvider.deleteSale(id)        // Delete sale
```

---

## Debugging Tips

### Enable Logging
```dart
// In main.dart
logger.info('ℹ️ App started');
logger.warning('⚠️ Something unusual');
logger.error('❌ Error occurred', error: exception);
```

### Check Sync Status
```dart
final syncQueue = getIt<SyncQueue>();
syncQueue.syncStatus.listen((status) {
  print('Sync status: $status'); // pending, syncing, synced
});
```

### Check Network Status
```dart
final connectivity = getIt<ConnectivityService>();
print('Is online: ${connectivity.isConnected}');
```

### Check Pending Operations
```dart
final localDataSource = getIt<LocalDataSource>();
final pending = await localDataSource.getPendingSyncOperations();
print('Pending syncs: ${pending.length}');
```

---

## Migration Checklist (Per Screen)

When migrating a screen:

- [ ] Replace `AppProvider` with specific provider
- [ ] Update state access: `.state.items` instead of `.items`
- [ ] Add error handling for `.state.error`
- [ ] Add loading indicator for `.state.isLoading`
- [ ] Replace Operations like `.add*()` with `.addItem()` etc.
- [ ] Use try-catch for possible exceptions
- [ ] Test on device (online & offline)
- [ ] Commit to git

---

## Key Numbers to Remember

| Metric | Value |
|--------|-------|
| Default pagination size | 50 items |
| Max retries | 3 attempts |
| Retry backoff | Exponential (100ms → 400ms) |
| Request timeout | 30 seconds |
| Sync timeout | 60 seconds |
| Database version | 9 (auto-migrates) |

---

## Command Reference

```bash
# Get packages
flutter pub get

# Analyze code
flutter analyze

# Format code
flutter format lib/

# Run on specific device
flutter run -d windows
flutter run -d chrome
flutter run -d edge

# Clean build
flutter clean && flutter pub get &&  flutter run

# Check for outdated packages
flutter pub outdated
```

---

## Documentation Files

- **SUMMARY_WHATS_DONE.md** ← Start here
- **ARCHITECTURE_REFACTOR_README.md** - Full overview
- **ARCHITECTURE_INTEGRATION_GUIDE.md** - How to migration 
- **IMPLEMENTATION_ROADMAP.md** - Step-by-step plan
- **ANALYTICS_SCREEN_EXAMPLE.dart** - Working example
- **QUICK_REFERENCE.md** ← You are here

---

## Need Help?

1. **Compilation error?** → Check imports match new structure
2. **Runtime error?** → Check service locator initialization
3. **Sync not working?** → Check connectivity service status
4. **Provider not updating?** → Ensure `notifyListeners()` called
5. **State not accessible?** → Use `.state.` prefix

---

**Remember:** Baby steps! Migrate one screen at a time. Test after each change. Commit frequently.

You got this! 💪🚀
