# Implementation Roadmap - Complete Migration Plan

## 🗺️ Overview
This document provides a step-by-step roadmap to complete the architecture refactor and migrate all 12 screens to the new clean architecture.

**Total Estimated Time:** 3-4 weeks (assuming 4 hours/day)
**Difficulty:** Medium
**Risk Level:** Low (new code parallel to existing)

---

## Phase 1: Foundation Setup (Week 1) ✅ COMPLETE

### ✅ 1.1 Core Infrastructure
- [x] Error handling & exception hierarchy
- [x] Constants & configuration
- [x] Logger utility
- [x] Retry service with exponential backoff
- [x] Service locator setup

### ✅ 1.2 Domain Layer
- [x] Entity models with timestamps
- [x] Abstract repository interfaces
- [x] Use cases (AddSale, CalculateProfit)

### ✅ 1.3 Data Layer
- [x] Remote datasource (Firebase)
- [x] Local datasource (SQLite)
- [x] Sync queue with conflict resolution
- [x] Repository implementations
- [x] Connectivity service

### ✅ 1.4 Initial Providers
- [x] InventoryProvider with state
- [x] SalesProvider with state
- [x] Main.dart initialization

---

## Phase 2: Screen Migration (Week 2-3) ⏳ IN PROGRESS

### Step 1: Inventory Screen (Day 1-2)

**File:** `lib/presentation/screens/inventory/inventory_screen.dart`

**Checklist:**
- [ ] Replace `AppProvider` with `InventoryProvider`
- [ ] Update state access: `appProvider.inventory` → `inventoryProvider.state.items`
- [ ] Add error handling for `state.error`
- [ ] Add loading indicator for `state.isLoading`
- [ ] Replace `addInventoryItem()` with `inventoryProvider.addItem()`
- [ ] Replace `updateInventoryItem()` with `inventoryProvider.updateItem()`
- [ ] Replace `deleteInventoryItem()` with `inventoryProvider.deleteItem()`

**Code Template:**
```dart
class InventoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: Consumer<InventoryProvider>(
        builder: (context, inventoryProvider, _) {
          if (inventoryProvider.state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (inventoryProvider.state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${inventoryProvider.state.error}'),
                  ElevatedButton(
                    onPressed: () => inventoryProvider.loadInventory(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            children: inventoryProvider.state.items
                .map((item) => InventoryItemTile(
                  item: item,
                  onEdit: () => _showEditDialog(context, item, inventoryProvider),
                  onDelete: () => _deleteItem(context, item.id, inventoryProvider),
                ))
                .toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Future<void> _deleteItem(
    BuildContext context,
    String itemId,
    InventoryProvider provider,
  ) async {
    try {
      await provider.deleteItem(itemId);
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
    }
  }
}
```

---

### Step 2: Sales Screen (Day 3-4)

**File:** `lib/presentation/screens/sales/sales_screen.dart`

**Checklist:**
- [ ] Replace `AppProvider` with `SalesProvider`
- [ ] Use `recordSale()` instead of `addSale()` (transactional)
- [ ] Handle `InsufficientStockException` specifically
- [ ] Add profit margin display per sale
- [ ] Show sync status if offline
- [ ] Display last sync time

**Key Changes:**
```dart
// OLD
await appProvider.addSale(sale);

// NEW - Transactional with auto inventory deduction
try {
  await salesProvider.recordSale(
    itemId: selectedItem.id,
    quantity: 5,
    sellingPrice: selectedItem.sellPrice * 5,
    createdBy: currentUser.uid,
  );
} on InsufficientStockException catch (e) {
  ErrorHandler.showErrorSnackBar(context, e);
} catch (e) {
  ErrorHandler.showErrorSnackBar(context, e);
}
```

---

### Step 3: Statistics Screen (Day 5)

**File:** `lib/presentation/screens/statistics/statistics_screen.dart`

**Checklist:**
- [ ] Create `AnalyticsProvider` with `AnalyticsState`
- [ ] Use `CalculateProfitUseCase` for KPI calculation
- [ ] Implement `GetAnalyticsDashboardUseCase` (create if needed)
- [ ] Add fl_chart visualizations
- [ ] Display: Revenue, Profit, Margin %, Top Selling Items
- [ ] Add date range selector
- [ ] Show low stock alerts

**Reference:** See `ANALYTICS_SCREEN_EXAMPLE.dart`

---

### Step 4: Dashboard Screen (Day 6)

**File:** `lib/presentation/screens/dashboard_screen.dart`

**Checklist:**
- [ ] Combine `InventoryProvider` + `SalesProvider`
- [ ] Display quick stats (today's revenue, low stock count)
- [ ] Show sync status from `SyncQueue`
- [ ] Display "Last synced" timestamp
- [ ] Add quick action buttons
- [ ] Show pending sync operations count

---

### Step 5: Deliveries Screen (Day 7)

**File:** `lib/presentation/screens/deliveries_screen.dart`

**Checklist:**
- [ ] Create `DeliveryProvider` if needed
- [ ] Use `InventoryProvider.updateItem()` for stock in/out
- [ ] Add delivery history
- [ ] Track delivery costs

---

### Step 6-12: Remaining Screens (Week 3)

**Order of Priority:**
6. [ ] Admin Screen - Use inventory/sales providers
7. [ ] Owner Dashboard - Combine analytics + inventory
8. [ ] Items Screen - Use inventory provider
9. [ ] Manage Requests - Keep existing (separate feature)
10. [ ] Join Workspace - Keep existing (separate feature)
11. [ ] Login Screen - Keep existing (auth layer)
12. [ ] Inventory Table - Use paginated inventory

---

## Phase 3: Advanced Features (Week 4) ⏳ FUTURE

### 3.1 Pagination Implementation

**For large inventory lists:**

```dart
// Create pagination provider
class PaginatedInventoryProvider extends ChangeNotifier {
  final FirestorePaginationService _paginationService;
  List<InventoryItem> _items = [];
  bool _hasMore = true;
  bool _isLoading = false;

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    // Load next 50 items
  }
}
```

### 3.2 Local Caching with Hive

**Add to pubspec.yaml:**
```yaml
hive: ^2.2.3
hive_flutter: ^1.1.0
```

**Usage:**
```dart
class HiveCache {
  late Box<InventoryItem> _inventoryBox;
  
  Future<void> initialize() async {
    Hive.registerAdapter(InventoryItemAdapter());
    _inventoryBox = await Hive.openBox<InventoryItem>('inventory');
  }
  
  Future<void> cacheItems(List<InventoryItem> items) async {
    await _inventoryBox.clear();
    await _inventoryBox.addAll(items);
  }
}
```

### 3.3 Background Sync with WorkManager

**Add to pubspec.yaml:**
```yaml
workmanager: ^0.5.1
```

**Setup periodic background sync:**
```dart
class BackgroundSyncService {
  void initializeBackgroundSync() {
    Workmanager().initialize(callbackDispatcher);
    Workmanager().registerPeriodicTask(
      'syncQueue',
      'sync',
      frequency: const Duration(minutes: 15),
    );
  }
  
  static void callbackDispatcher() async {
    await ServiceLocator.setup();
    final syncQueue = getIt<SyncQueue>();
    await syncQueue.processPendingOperations();
  }
}
```

### 3.4 Real-time Collaboration

**Using Firestore listeners:**
```dart
// Already set up in RemoteDataSource
Stream<List<Sale>> getSalesStream(String shopId) {
  return _firestore
      .collection('shops')
      .doc(shopId)
      .collection('sales')
      .snapshots()
      .map(...);
}

// Use in provider:
_firebaseService.getSalesStream(shopId).listen((sales) {
  _state = _state.copyWith(sales: sales);
  notifyListeners();
});
```

---

## 🧪 Testing (Parallel with Development)

### Unit Tests Example

```dart
// test/usecases/add_sale_usecase_test.dart
void main() {
  group('AddSaleUseCase', () {
    late AddSaleUseCase usecase;
    late MockSalesRepository mockSalesRepo;
    late MockInventoryRepository mockInventoryRepo;
    late MockNotificationService mockNotificationService;

    setUp(() {
      mockSalesRepo = MockSalesRepository();
      mockInventoryRepo = MockInventoryRepository();
      mockNotificationService = MockNotificationService();
      
      usecase = AddSaleUseCase(
        salesRepository: mockSalesRepo,
        inventoryRepository: mockInventoryRepo,
        notificationService: mockNotificationService,
      );
    });

    test('should deduct inventory when sale is recorded', () async {
      // Arrange
      when(mockInventoryRepo.getItem(any, any)).thenAnswer(
        (_) async => InventoryItem(
          id: '1',
          name: 'Coffee',
          quantity: 100,
          buyPrice: 10,
          sellPrice: 20,
          lowStockThreshold: 10,
          createdBy: 'user1',
        ),
      );

      // Act
      final sale = await usecase(
        shopId: 'shop1',
        itemId: '1',
        quantity: 5,
        sellingPrice: 20,
        createdBy: 'user1',
      );

      // Assert
      verify(mockInventoryRepo.updateItem(any, any)).called(1);
      expect(sale.quantity, 5);
    });

    test('should throw InsufficientStockException when stock is low', () async {
      // Arrange
      when(mockInventoryRepo.getItem(any, any)).thenAnswer(
        (_) async => InventoryItem(
          id: '1',
          name: 'Coffee',
          quantity: 2,  // Only 2 left
          buyPrice: 10,
          sellPrice: 20,
          lowStockThreshold: 10,
          createdBy: 'user1',
        ),
      );

      // Act & Assert
      expect(
        () => usecase(
          shopId: 'shop1',
          itemId: '1',
          quantity: 5,  // Need 5, have 2
          sellingPrice: 20,
          createdBy: 'user1',
        ),
        throwsA(isA<InsufficientStockException>()),
      );
    });
  });
}
```

---

## ⚡ Daily Checklist

### Each Day:
- [ ] Run `flutter pub get` after any pubspec changes
- [ ] Test changes on device/emulator
- [ ] Commit changes to git
- [ ] Update CHANGELOG with date
- [ ] Run `flutter analyze` for lint errors
- [ ] Check for unused imports

---

## 🚨 Common Issues & Solutions

### Issue 1: Provider not updating UI
**Solution:** Ensure `notifyListeners()` is called after state change

### Issue 2: Service Locator initialization error
**Solution:** Verify `ServiceLocator.setup()` is called in `main()` before `runApp()`

### Issue 3: Database migration errors
**Solution:** Increment `_databaseVersion` in `DatabaseHelper` and add migration logic

### Issue 4: Sync conflicts
**Solution:** Firestore security rules enforce last-write-wins with timestamps

### Issue 5: Offline data not syncing
**Solution:** Check `ConnectivityService` status and `SyncQueue` logs

---

## 📈 Progress Tracking

Create a progress file to track completion:

```
MIGRATION_STATUS.md

Phase 1: Foundation ✅ 100%
Phase 2: Screen Migration 🔄 0%
  - Inventory Screen: ⏳ 0%
  - Sales Screen: ⏳ 0%
  - Statistics Screen: ⏳ 0%
  - Dashboard Screen: ⏳ 0%
  - ... (remaining)
Phase 3: Advanced Features ⏳ 0%
Testing & QA: ⏳ 0%
```

---

## 🎯 Success Criteria

- [ ] All 12 screens using new providers
- [ ] No compile errors or warnings
- [ ] All use cases have unit tests
- [ ] Offline sync working (tested by disconnecting network)
- [ ] Inventory auto-deducts on sale
- [ ] Profit calculations displayed
- [ ] Error handling for all edge cases
- [ ] App runs on Android, iOS, Web successfully

---

## 📞 Support & Questions

If you encounter issues:
1. Check logs: Use `logger.info()` and `logger.error()`
2. Review examples: See `ANALYTICS_SCREEN_EXAMPLE.dart`
3. Read integration guide: `ARCHITECTURE_INTEGRATION_GUIDE.md`
4. Check tests for usage patterns

---

**Next Action:** Start with Step 1 (Inventory Screen) using the provided code template.

Good luck! 🚀
