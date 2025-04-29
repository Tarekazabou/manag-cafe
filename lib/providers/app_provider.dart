import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart'; // For compute
import '../models/inventory_item.dart';
import '../models/sale.dart';
import '../models/inventory_snapshot.dart';
import '../services/database_helper.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';

class AppProvider with ChangeNotifier {
  List<InventoryItem> _inventory = [];
  List<Sale> _sales = [];
  List<InventorySnapshot> _snapshots = [];
  Map<String, InventoryItem> get itemMap =>
      {for (var item in _inventory) item.id: item};
  List<InventoryItem> get inventory => _inventory;
  List<Sale> get sales => _sales;
  List<InventorySnapshot> get snapshots => _snapshots;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();
  final Uuid _uuid = Uuid();

  String? _shopId;
  String? _shopCode;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEmployee = false;

  String? get shopId => _shopId;
  String? get shopCode => _shopCode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEmployee => _isEmployee;

  AppProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;
    _isLoading = true;
    notifyListeners();

    try {
      _authService.authStateChanges.listen((user) async {
        await _handleAuthStateChange(user);
      });
    } catch (e) {
      _errorMessage = 'Error during AppProvider initialization: $e';
      print(_errorMessage);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _handleAuthStateChange(User? user) async {
    if (user != null) {
      await _loadUserShopData(user);
    } else {
      _resetState('User not authenticated.');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadUserShopData(User user) async {
    try {
      final userSnapshot = await FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .get();
      if (!userSnapshot.exists) {
        _resetState('User data not found.');
        return;
      }

      final userData = userSnapshot.value as Map<dynamic, dynamic>;
      _shopId = userData['shopId']?.toString();

      if (_shopId == null) {
        _resetState('No shop assigned to this user.');
        return;
      }

      bool isEmployee = await _firebaseService.isEmployee(_shopId!, user.uid);
      final shopSnapshot =
          await FirebaseDatabase.instance.ref().child('shops').child(_shopId!).get();
      if (!shopSnapshot.exists) {
        _resetState('Shop data not found for shopId: $_shopId');
        return;
      }

      bool isOwner = (shopSnapshot.value as Map)['ownerId'] == user.uid;
      if (!isEmployee && !isOwner) {
        _resetState('You are not authorized to access this shop (shopId: $_shopId).');
        return;
      }

      _isEmployee = isEmployee;
      _shopCode = (shopSnapshot.value as Map)['code'] as String?;
      await _initializeInventory();
      await _loadData();
      _setupFirebaseSync();
      _isInitialized = true;
    } catch (e) {
      _resetState('Error loading user shop data: $e');
    }
  }

  void _resetState(String errorMessage) {
    _shopId = null;
    _shopCode = null;
    _inventory = [];
    _sales = [];
    _snapshots = [];
    _isEmployee = false;
    _errorMessage = errorMessage;
    print('State reset with error: $errorMessage');
  }

  Future<void> _initializeInventory() async {
    try {
      final existingItems = await _dbHelper.getInventoryItems();
      final requiredItems = [
        {'name': 'G. 12', 'isSellable': true},
        {'name': 'G. 25', 'isSellable': true},
        {'name': 'Sugar', 'isSellable': false},
        {'name': 'Vanilla Syrup', 'isSellable': false},
        {'name': 'Water Bottle 1.5L', 'isSellable': true},
      ];
      for (var itemData in requiredItems) {
        final itemName = itemData['name'] as String;
        if (!existingItems.any((item) => item.name == itemName)) {
          print('Adding missing item: $itemName for shopId: $_shopId');
          final item = InventoryItem(
            id: _uuid.v4(),
            name: itemName,
            quantity: itemName == 'Sugar' ? 10.0 : 100.0,
            buyPrice: 1.0,
            sellPrice: 2.0,
            lowStockThreshold: itemName == 'Sugar' ? 1.0 : 10.0,
            isSellable: itemData['isSellable'] as bool,
          );
          await _dbHelper.insertInventoryItem(item);
          if (_shopId != null) {
            await _firebaseService.saveInventoryItem(_shopId!, item);
          }
        }
      }
      final initializedItems = await _dbHelper.getInventoryItems();
      print(
          'Initialized inventory for shopId: $_shopId: ${initializedItems.map((item) => item.name).toList()}');
    } catch (e) {
      _errorMessage = 'Error initializing inventory for shopId: $_shopId: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Future<void> _loadData() async {
    try {
      _inventory = await _dbHelper.getInventoryItems();
      _sales = await _dbHelper.getSales();
      _snapshots = await _dbHelper.getSnapshots();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading data for shopId: $_shopId: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  static Future<void> _syncInventoryToSQLiteIsolate(List<InventoryItem> items) async {
    for (var item in items) {
      await DatabaseHelper.instance.insertInventoryItem(item);
    }
  }

  Future<void> _syncInventoryToSQLite(List<InventoryItem> items) async {
    try {
      await compute(_syncInventoryToSQLiteIsolate, items);
    } catch (e) {
      print('Error syncing inventory to SQLite for shopId: $_shopId: $e');
    }
  }

  Future<void> _syncSalesToSQLite(List<Sale> sales) async {
    try {
      for (var sale in sales) {
        await _dbHelper.insertSale(sale);
      }
    } catch (e) {
      print('Error syncing sales to SQLite for shopId: $_shopId: $e');
    }
  }

  Future<void> _syncSnapshotsToSQLite(List<InventorySnapshot> snapshots) async {
    try {
      for (var snapshot in snapshots) {
        await _dbHelper.insertSnapshot(snapshot);
      }
    } catch (e) {
      print('Error syncing snapshots to SQLite for shopId: $_shopId: $e');
    }
  }

  void _setupFirebaseSync() {
    if (_shopId == null) {
      print('Cannot setup Firebase sync: shopId is null');
      return;
    }
    try {
      _firebaseService.getInventoryStream(_shopId!).listen((items) async {
        print(
            'Synced inventory from Firebase for shopId: $_shopId: ${items.map((item) => item.name).toList()}');
        _inventory = items;
        await _syncInventoryToSQLite(items);
        notifyListeners();
      }, onError: (e) {
        _errorMessage = 'Error syncing inventory from Firebase for shopId: $_shopId: $e';
        print(_errorMessage);
      });

      _firebaseService.getSalesStream(_shopId!).listen((sales) async {
        print('Synced sales from Firebase for shopId: $_shopId: ${sales.length} sales');
        _sales = sales;
        await _syncSalesToSQLite(sales);
        notifyListeners();
      }, onError: (e) {
        print('Error syncing sales from Firebase for shopId: $_shopId: $e');
      });

      _firebaseService.getSnapshotsStream(_shopId!).listen((snapshots) async {
        print(
            'Synced snapshots from Firebase for shopId: $_shopId: ${snapshots.length} snapshots');
        _snapshots = snapshots;
        await _syncSnapshotsToSQLite(snapshots);
        notifyListeners();
      }, onError: (e) {
        print('Error syncing snapshots from Firebase for shopId: $_shopId: $e');
      });
    } catch (e) {
      _errorMessage = 'Error setting up Firebase sync for shopId: $_shopId: $e';
      print(_errorMessage);
    }
  }

  Future<bool> hasPermission() async {
    if (_shopId == null) {
      _errorMessage = 'Cannot perform action: shopId is null';
      notifyListeners();
      return false;
    }
    final isEmployee = await _firebaseService.isEmployee(_shopId!, _authService.currentUser!.uid);
    final isOwner = await _isOwner();
    return isEmployee || isOwner;
  }

  Future<bool> addInventoryItem(InventoryItem item) async {
    if (!await hasPermission()) {
      return false;
    }
    try {
      await _dbHelper.insertInventoryItem(item);
      if (_shopId != null) {
        await _firebaseService.saveInventoryItem(_shopId!, item);
      }
      return true;
    } catch (e) {
      _errorMessage = 'Error adding inventory item for shopId: $_shopId: $e';
      print(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteInventoryItem(String id) async {
    if (!await hasPermission()) {
      return;
    }
    try {
      await _dbHelper.deleteInventoryItem(id);
      if (_shopId != null) {
        await FirebaseDatabase.instance
            .ref()
            .child('shops')
            .child(_shopId!)
            .child('inventory')
            .child(id)
            .remove();
      }
    } catch (e) {
      _errorMessage = 'Error deleting inventory item for shopId: $_shopId: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    if (!await hasPermission()) {
      return;
    }
    try {
      final index = _inventory.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _inventory[index] = item;
        await _dbHelper.updateInventoryItem(item);
        if (_shopId != null) {
          await _firebaseService.saveInventoryItem(_shopId!, item);
        }
      }
    } catch (e) {
      _errorMessage = 'Error updating inventory item for shopId: $_shopId: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Future<void> toggleSellableStatus(String itemId, bool isSellable) async {
    if (!await hasPermission()) {
      return;
    }
    try {
      final itemIndex = _inventory.indexWhere((i) => i.id == itemId);
      if (itemIndex != -1) {
        final item = _inventory[itemIndex];
        final updatedItem = InventoryItem(
          id: item.id,
          name: item.name,
          quantity: item.quantity,
          buyPrice: item.buyPrice,
          sellPrice: item.sellPrice,
          lowStockThreshold: item.lowStockThreshold,
          isSellable: isSellable,
        );
        await updateInventoryItem(updatedItem);
      }
    } catch (e) {
      _errorMessage =
          'Error toggling sellable status for item $itemId in shopId: $_shopId: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Future<void> addSale(Sale sale) async {
    if (!await hasPermission()) {
      return;
    }
    try {
      await _dbHelper.insertSale(sale);
      if (_shopId != null) {
        await _firebaseService.saveSale(_shopId!, sale);
      }
    } catch (e) {
      _errorMessage = 'Error adding sale for shopId: $_shopId: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Future<void> deleteSale(String id) async {
    if (!await hasPermission()) {
      return;
    }
    try {
      await _dbHelper.deleteSale(id);
      if (_shopId != null) {
        await _firebaseService.deleteSale(_shopId!, id);
      }
    } catch (e) {
      _errorMessage = 'Error deleting sale for shopId: $_shopId: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Future<void> addSnapshot(InventorySnapshot snapshot) async {
    if (!await hasPermission()) {
      return;
    }
    try {
      await _dbHelper.insertSnapshot(snapshot);
      if (_shopId != null) {
        await _firebaseService.saveSnapshot(_shopId!, snapshot);
      }
    } catch (e) {
      _errorMessage = 'Error adding snapshot for shopId: $_shopId: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Future<void> recordDelivery(
      String itemId, double deliveredQuantity, double totalCost,
      {String timeSlot = '14:00', String weather = 'Nice'}) async {
    if (!await hasPermission()) {
      return;
    }
    try {
      final item = _inventory.firstWhere((i) => i.id == itemId);
      final updatedItem = InventoryItem(
        id: item.id,
        name: item.name,
        quantity: item.quantity + deliveredQuantity,
        buyPrice: totalCost / deliveredQuantity,
        sellPrice: item.sellPrice,
        lowStockThreshold: item.lowStockThreshold,
        isSellable: item.isSellable,
      );
      await updateInventoryItem(updatedItem);

      final snapshot = InventorySnapshot(
        id: _uuid.v4(),
        itemId: itemId,
        quantity: deliveredQuantity,
        timestamp: DateTime.now().toIso8601String(),
        timeSlot: timeSlot,
        weather: weather,
      );
      await addSnapshot(snapshot);
    } catch (e) {
      _errorMessage = 'Error recording delivery for shopId: $_shopId: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Future<void> calculateAndSaveSessionSales(
      String session, DateTime start, DateTime end, String date) async {
    if (!await hasPermission()) {
      return;
    }
    try {
      final startStr = start.toIso8601String().substring(0, 10);
      final startTimeSlot = start.hour < 14 ? '00:00' : '14:00';
      final endTimeSlot = end.hour < 14 ? '00:00' : '14:00';

      final startQuantities = getQuantitiesForTimeSlot(startStr, startTimeSlot);
      final endQuantities = getQuantitiesForTimeSlot(startStr, endTimeSlot);

      final Map<String, double> deliveredQuantities = {};
      for (var item in _inventory) {
        final delivered = await getDeliveredQuantity(item.id, date);
        deliveredQuantities[item.id] = delivered;
      }

      for (var item in _inventory) {
        final startQty = startQuantities[item.name] ?? -1;
        final endQty = endQuantities[item.name] ?? -1;
        if (startQty >= 0 && endQty >= 0 && item.isSellable) {
          final delivered = deliveredQuantities[item.id] ?? 0.0;
          final consumption = startQty + delivered - endQty;
          if (consumption > 0) {
            final sale = Sale(
              id: _uuid.v4(),
              itemName: item.name,
              quantity: consumption.toInt(),
              sellingPrice: item.sellPrice,
              date: date,
            );
            await addSale(sale);
          }
        }
      }
      notifyListeners();
    } catch (e) {
      _errorMessage =
          'Error calculating session sales for $session in shopId: $_shopId: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Map<String, Map<String, Map<String, double>>> getSessionStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final todayStr = today.toIso8601String().substring(0, 10);
    final yesterdayStr = yesterday.toIso8601String().substring(0, 10);

    final session1Stats = calculateSessionStats(todayStr, '00:00', '14:00');
    final session2Stats = calculateSessionStats(yesterdayStr, '14:00', '00:00');

    return {
      'session1': session1Stats,
      'session2': session2Stats,
    };
  }

  Map<String, Map<String, double>> calculateSessionStats(
      String date, String startTimeSlot, String endTimeSlot) {
    final Map<String, Map<String, double>> stats = {};
    for (var item in _inventory) {
      stats[item.name] = {
        'quantitySold': 0.0,
        'totalSpent': 0.0,
        'totalEarned': 0.0,
        'profit': 0.0,
      };
    }

    final startQuantities = getQuantitiesForTimeSlot(date, startTimeSlot);
    final endQuantities = getQuantitiesForTimeSlot(date, endTimeSlot);

    final Map<String, double> deliveredQuantities = {};
    for (var item in _inventory) {
      final delivered = getDeliveredQuantitySync(item.id, date);
      deliveredQuantities[item.id] = delivered;
    }

    for (var item in _inventory) {
      final startQty = startQuantities[item.name] ?? -1;
      final endQty = endQuantities[item.name] ?? -1;
      if (startQty >= 0 && endQty >= 0 && item.isSellable) {
        final delivered = deliveredQuantities[item.id] ?? 0.0;
        final consumption = startQty + delivered - endQty;
        if (consumption > 0) {
          stats[item.name]!['quantitySold'] = consumption;
          stats[item.name]!['totalEarned'] = consumption * item.sellPrice;
          stats[item.name]!['totalSpent'] = consumption * item.buyPrice;
          stats[item.name]!['profit'] =
              stats[item.name]!['totalEarned']! - stats[item.name]!['totalSpent']!;
        }
      }
    }

    return stats;
  }

  double getDeliveredQuantitySync(String itemId, String date) {
    final snapshots = _snapshots
        .where((s) => s.itemId == itemId && s.timestamp.startsWith(date))
        .toList();
    final double result = snapshots.fold(
        0.0, (double sum, InventorySnapshot s) => sum + (s.quantity > 0 ? s.quantity : 0));
    return result;
  }

  Map<String, Map<String, double>> calculateSalesStats() {
    final Map<String, Map<String, double>> stats = {};
    for (var item in _inventory) {
      stats[item.name] = {
        'quantitySold': 0.0,
        'totalSpent': 0.0,
        'totalEarned': 0.0,
        'profit': 0.0,
      };
    }
    for (var sale in _sales) {
      if (stats.containsKey(sale.itemName)) {
        final item = itemMap.values.firstWhere((item) => item.name == sale.itemName);
        if (item.isSellable) {
          stats[sale.itemName]!['quantitySold'] =
              (stats[sale.itemName]!['quantitySold']! + sale.quantity);
          stats[sale.itemName]!['totalEarned'] =
              (stats[sale.itemName]!['totalEarned']! +
                  (sale.quantity * sale.sellingPrice));
          stats[sale.itemName]!['totalSpent'] =
              (stats[sale.itemName]!['totalSpent']! +
                  (sale.quantity * item.buyPrice));
          stats[sale.itemName]!['profit'] =
              stats[sale.itemName]!['totalEarned']! - stats[sale.itemName]!['totalSpent']!;
        }
      }
    }
    return stats;
  }

  Future<void> updateInventoryAndSales(String date, String timeSlot) async {
    if (!await hasPermission()) {
      return;
    }
    try {
      final quantities = getQuantitiesForTimeSlot(date, timeSlot);
      final consumption = calculateConsumption(date);

      for (var item in _inventory) {
        if (quantities.containsKey(item.name) && item.isSellable) {
          final newQty = quantities[item.name]!;
          final updatedItem = InventoryItem(
            id: item.id,
            name: item.name,
            quantity: newQty,
            buyPrice: item.buyPrice,
            sellPrice: item.sellPrice,
            lowStockThreshold: item.lowStockThreshold,
            isSellable: item.isSellable,
          );
          await updateInventoryItem(updatedItem);

          final consumed = consumption[item.name] ?? 0;
          if (consumed > 0) {
            final sale = Sale(
              id: _uuid.v4(),
              itemName: item.name,
              quantity: consumed.toInt(),
              sellingPrice: item.sellPrice,
              date: date,
            );
            await addSale(sale);
          }
        }
      }
    } catch (e) {
      _errorMessage = 'Error updating inventory and sales for shopId: $_shopId: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Future<double> getDeliveredQuantity(String itemId, String date) async {
    try {
      final snapshots = _snapshots
          .where((s) => s.itemId == itemId && s.timestamp.startsWith(date))
          .toList();
      final result = snapshots.fold(
          0.0, (double sum, InventorySnapshot s) => sum + (s.quantity > 0 ? s.quantity : 0));
      return result;
    } catch (e) {
      print('Error getting delivered quantity for shopId: $_shopId: $e');
      return 0.0;
    }
  }

  double get totalRevenue => _sales.fold(0, (sum, sale) {
        final item = itemMap.values.firstWhere((item) => item.name == sale.itemName);
        return item.isSellable ? sum + sale.quantity * sale.sellingPrice : sum;
      });

  double get totalCost =>
      _inventory.fold(0, (sum, item) => sum + item.quantity * item.buyPrice);

  double get profit => totalRevenue - totalCost;

  List<InventoryItem> get lowStockItems =>
      _inventory.where((item) => item.quantity <= item.lowStockThreshold).toList();

  Map<String, double> getQuantitiesForTimeSlot(String date, String timeSlot) {
    final Map<String, double> quantities = {};
    final dateTimeStr = '$date $timeSlot';
    final targetTime = DateTime.parse(dateTimeStr);

    for (var item in _inventory) {
      final relevantSnapshots = _snapshots
          .where((s) =>
              s.itemId == item.id &&
              DateTime.parse(s.timestamp).isBefore(targetTime))
          .toList();

      if (relevantSnapshots.isNotEmpty) {
        relevantSnapshots.sort((a, b) =>
            DateTime.parse(b.timestamp).compareTo(DateTime.parse(a.timestamp)));
        quantities[item.name] = relevantSnapshots.first.quantity;
      }
    }

    return quantities;
  }

  Map<String, double> calculateConsumption(String date) {
    final Map<String, double> consumption = {};
    final quantities00 = getQuantitiesForTimeSlot(date, '00:00');
    final quantities14 = getQuantitiesForTimeSlot(date, '14:00');

    for (var item in _inventory) {
      final qty00 = quantities00[item.name] ?? -1;
      final qty14 = quantities14[item.name] ?? -1;
      if (qty00 >= 0 && qty14 >= 0 && item.isSellable) {
        consumption[item.name] = qty14 - qty00;
      }
    }

    return consumption;
  }

  Map<String, dynamic> calculateInventoryStats(String date,
      {double discrepancyThreshold = 0.05}) {
    final g12Item = _inventory.firstWhere((item) => item.name.contains('G. 12'),
        orElse: () => InventoryItem(
            id: '',
            name: 'G. 12',
            quantity: 0,
            buyPrice: 0,
            sellPrice: 0,
            lowStockThreshold: 0,
            isSellable: true));
    final g25Item = _inventory.firstWhere((item) => item.name.contains('G. 25'),
        orElse: () => InventoryItem(
            id: '',
            name: 'G. 25',
            quantity: 0,
            buyPrice: 0,
            sellPrice: 0,
            lowStockThreshold: 0,
            isSellable: true));
    final sugarItem = _inventory.firstWhere((item) => item.name.contains('Sugar'),
        orElse: () => InventoryItem(
            id: '',
            name: 'Sugar',
            quantity: 0,
            buyPrice: 0,
            sellPrice: 0,
            lowStockThreshold: 0,
            isSellable: false));

    final g12Name = g12Item.name;
    final g25Name = g25Item.name;
    final sugarName = sugarItem.name;

    final Map<String, double> itemStatsTemplate = {
      'starting': 0.0,
      'expectedUsed': 0.0,
      'actualUsed': 0.0,
      'ending': 0.0,
      'discrepancy': 0.0,
    };

    final Map<String, dynamic> stats = {
      g12Name: Map<String, double>.from(itemStatsTemplate),
      g25Name: Map<String, double>.from(itemStatsTemplate),
      sugarName: Map<String, double>.from(itemStatsTemplate),
      'sugarCubes': 0.0,
      'issues': <String>[],
    };

    print('Inventory items for shopId: $_shopId: ${_inventory.map((item) => item.name).toList()}');
    if (g12Item.id.isEmpty) {
      (stats['issues'] as List<String>).add('$g12Name not found in inventory');
    }
    if (g25Item.id.isEmpty) {
      (stats['issues'] as List<String>).add('$g25Name not found in inventory');
    }
    if (sugarItem.id.isEmpty) {
      (stats['issues'] as List<String>).add('$sugarName not found in inventory');
    }

    final dailySales = _sales.where((sale) => sale.date.startsWith(date)).toList();
    int g12Sold = 0;
    int g25Sold = 0;
    for (var sale in dailySales) {
      final item = itemMap.values.firstWhere((item) => item.name == sale.itemName);
      if (item.isSellable) {
        if (sale.itemName.contains('G. 12')) {
          g12Sold += sale.quantity;
        } else if (sale.itemName.contains('G. 25')) {
          g25Sold += sale.quantity;
        }
      }
    }

    (stats[g12Name] as Map<String, double>)['expectedUsed'] = g12Sold.toDouble();
    (stats[g25Name] as Map<String, double>)['expectedUsed'] = g25Sold.toDouble();

    final totalCoffees = g12Sold + g25Sold;
    stats['sugarCubes'] = totalCoffees * 3.0;
    (stats[sugarName] as Map<String, double>)['expectedUsed'] =
        (stats['sugarCubes'] as double) / 300.0;

    final quantities14 = getQuantitiesForTimeSlot(date, '14:00');
    final quantities00 = getQuantitiesForTimeSlot(date, '00:00');

    for (var itemName in [g12Name, g25Name, sugarName]) {
      if (!quantities14.containsKey(itemName) || !quantities00.containsKey(itemName)) {
        final missingSlots = [];
        if (!quantities14.containsKey(itemName)) missingSlots.add('14:00');
        if (!quantities00.containsKey(itemName)) missingSlots.add('00:00');
        (stats[itemName] as Map<String, double>)['actualUsed'] = -1;
        (stats['issues'] as List<String>).add(
            'No inventory snapshot data for $itemName on $date at ${missingSlots.join(" and ")}');
        continue;
      }

      final qty14 = quantities14[itemName]!;
      final qty00 = quantities00[itemName]!;
      final itemStats = stats[itemName] as Map<String, double>;
      itemStats['starting'] = qty14;
      itemStats['ending'] = qty00;
      itemStats['actualUsed'] = qty14 - qty00;
      itemStats['discrepancy'] = itemStats['actualUsed']! - itemStats['expectedUsed']!;

      final expected = itemStats['expectedUsed']!;
      final discrepancy = itemStats['discrepancy']!;
      if (expected > 0 && (discrepancy.abs() / expected) > discrepancyThreshold) {
        if (discrepancy > 0) {
          (stats['issues'] as List<String>).add(
              'Possible wastage/theft: ${discrepancy.abs().toStringAsFixed(1)} extra $itemName used');
        } else {
          (stats['issues'] as List<String>).add(
              'Possible recording error: ${discrepancy.abs().toStringAsFixed(1)} less $itemName used than expected');
        }
      }
    }

    print('Stats for $date in shopId: $_shopId: $stats');
    return stats;
  }

  Future<bool> _isOwner() async {
    final user = _authService.currentUser;
    if (user == null || _shopId == null) return false;
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref()
          .child('shops')
          .child(_shopId!)
          .child('ownerId')
          .get();
      return snapshot.exists && snapshot.value == user.uid;
    } catch (e) {
      print('Error checking owner status for shopId: $_shopId: $e');
      return false;
    }
  }

  Future<void> requestToJoinShop(String shopCode) async {
    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('User not logged in');
      await _authService.requestToJoin(user.uid, shopCode);
      _errorMessage = 'Request to join shop sent successfully.';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error requesting to join shop: $e';
      print(_errorMessage);
      notifyListeners();
    }
  }

  Future<String> generateShopCode(String shopName) async {
    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('User not logged in');
      final code = await _authService.generateShopCode(user.uid, shopName);
      _shopId = (await FirebaseDatabase.instance
              .ref()
              .child('shops')
              .orderByChild('code')
              .equalTo(code)
              .get())
          .children
          .first
          .key;
      _shopCode = code;
      notifyListeners();
      return code;
    } catch (e) {
      _errorMessage = 'Error generating shop code: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Stream<Map<String, dynamic>> getPendingRequests() {
    if (_shopId == null) {
      print('Cannot get pending requests: shopId is null');
      return Stream.value({});
    }
    return _firebaseService.getPendingRequests(_shopId!);
  }

  Future<void> manageRequest(String userId, bool approve) async {
    try {
      if (_shopId == null) throw Exception('Shop ID not set');
      final user = _authService.currentUser;
      if (user == null) throw Exception('User not logged in');
      final shopSnapshot =
          await FirebaseDatabase.instance.ref().child('shops').child(_shopId!).get();
      if (!shopSnapshot.exists || (shopSnapshot.value as Map)['ownerId'] != user.uid) {
        throw Exception('Only the shop owner can manage requests.');
      }
      await _authService.manageRequest(_shopId!, userId, approve);
      _errorMessage =
          approve ? 'Request approved successfully.' : 'Request rejected successfully.';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error managing request for shopId: $_shopId: $e';
      print(_errorMessage);
      notifyListeners();
    }
  }
}