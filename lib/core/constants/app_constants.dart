class AppConstants {
  // Routes
  static const String routeHome = '/home';
  static const String routeLogin = '/login';
  static const String routeInventory = '/inventory';
  static const String routeSales = '/sales';
  static const String routeStatistics = '/statistics';
  static const String routeDeliveries = '/deliveries';
  static const String routeAdmin = '/admin';
  static const String routeManageRequests = '/manage_requests';

  // Firebase collections
  static const String collectionUsers = 'users';
  static const String collectionShops = 'shops';
  static const String collectionInventory = 'inventory';
  static const String collectionSales = 'sales';
  static const String collectionSnapshots = 'snapshots';
  static const String collectionSyncQueue = 'sync_queue';

  // Database tables
  static const String tableInventoryItems = 'inventory_items';
  static const String tableSales = 'sales';
  static const String tableSnapshots = 'snapshots';
  static const String tableSyncQueue = 'sync_queue';

  // Feature flags
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = true;
  static const int paginationPageSize = 50;
  static const int syncRetryCount = 3;
  
  // Timeouts
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration syncTimeout = Duration(seconds: 60);

  // Inventory defaults
  static const List<Map<String, dynamic>> defaultInventoryItems = [
    {'name': 'G. 12', 'isSellable': true},
    {'name': 'G. 25', 'isSellable': true},
    {'name': 'Sugar', 'isSellable': false},
    {'name': 'Vanilla Syrup', 'isSellable': false},
    {'name': 'Water Bottle 1.5L', 'isSellable': true},
  ];
}

class Colors {
  static const int primary = 0xFF4A2F1A;      // Dark brown
  static const int secondary = 0xFFDAB49D;    // Tan/beige
  static const int surface = 0xFFF5F5F5;      // Light
  static const int onPrimary = 0xFFFFFFFF;    // White
}
