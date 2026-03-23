/**
 * ARCHITECTURE INTEGRATION GUIDE
 * 
 * This document shows how to integrate the new clean architecture
 * with your existing screens and providers.
 * 
 * =================================================================
 * PHASE 1: SETUP (ALREADY DONE)
 * =================================================================
 * 
 * ✅ Core layer created:
 *    - Error handling (AppException, ErrorHandler)
 *    - Constants (AppConstants)
 *    - Logger utility
 *    - UID generator
 *    - Retry service
 * 
 * ✅ Domain layer created:
 *    - Entities (InventoryItem, Sale, InventorySnapshot)
 *    - Repositories (Abstract interfaces)
 *    - Use cases (AddSaleUseCase, CalculateProfitUseCase)
 * 
 * ✅ Data layer created:
 *    - Datasources (RemoteDataSource, LocalDataSource)
 *    - Repository implementations
 *    - Connectivity service
 *    - Sync queue with conflict resolution
 * 
 * ✅ Presentation layer:
 *    - New providers with state classes
 *    - Service locator setup
 * 
 * =================================================================
 * PHASE 2: INTEGRATING EXISTING SCREENS
 * =================================================================
 * 
 * Before refactoring screens, you need to:
 * 
 * 1. UPDATE main.dart MultiProvider setup:
 * 
 *    class CoffeeShopManagerApp extends StatelessWidget {
 *      @override
 *      Widget build(BuildContext context) {
 *        return MultiProvider(
 *          providers: [
 *            // Auth provider (keep existing)
 *            ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
 *            
 *            // New inventory provider
 *            ProxyProvider<AuthProvider, InventoryProvider>(
 *              create: (_) => InventoryProvider(
 *                repository: getIt<InventoryRepository>(),
 *                shopId: _getShopId(context),
 *              ),
 *              update: (_, auth, __) => InventoryProvider(
 *                repository: getIt<InventoryRepository>(),
 *                shopId: auth.state.user?.shopId ?? '',
 *              ),
 *            ),
 *            
 *            // New sales provider
 *            ProxyProvider2<AuthProvider, InventoryProvider, SalesProvider>(
 *              create: (_) => SalesProvider(
 *                addSaleUseCase: AddSaleUseCase(...),
 *                salesRepository: getIt<SalesRepository>(),
 *                shopId: _getShopId(context),
 *              ),
 *              update: (_, auth, inventory, __) => SalesProvider(
 *                addSaleUseCase: AddSaleUseCase(...),
 *                salesRepository: getIt<SalesRepository>(),
 *                shopId: auth.state.user?.shopId ?? '',
 *              ),
 *            ),
 *          ],
 *          child: MaterialApp(...),
 *        );
 *      }
 *    }
 * 
 * 2. UPDATE existing screens to use new providers:
 * 
 *    Example: sales_screen.dart
 * 
 *    OLD (Before):
 *    class SalesScreen extends StatelessWidget {
 *      @override
 *      Widget build(BuildContext context) {
 *        final appProvider = Provider.of<AppProvider>(context);
 *        return ListView(
 *          children: appProvider.sales.map((sale) => ...),
 *        );
 *      }
 *    }
 * 
 *    NEW (After):
 *    class SalesScreen extends StatelessWidget {
 *      @override
 *      Widget build(BuildContext context) {
 *        return Consumer<SalesProvider>(
 *          builder: (context, salesProvider, _) {
 *            if (salesProvider.state.isLoading) {
 *              return const Center(child: CircularProgressIndicator());
 *            }
 *            
 *            if (salesProvider.state.error != null) {
 *              return Center(
 *                child: Column(
 *                  mainAxisAlignment: MainAxisAlignment.center,
 *                  children: [
 *                    Text('Error: ${salesProvider.state.error}'),
 *                    ElevatedButton(
 *                      onPressed: () => salesProvider.loadSales(),
 *                      child: const Text('Retry'),
 *                    ),
 *                  ],
 *                ),
 *              );
 *            }
 *            
 *            return ListView(
 *              children: salesProvider.state.sales
 *                  .map((sale) => SaleListTile(sale: sale))
 *                  .toList(),
 *            );
 *          },
 *        );
 *      }
 *    }
 * 
 * 3. UPDATE screens to handle errors properly:
 * 
 *    class AddSaleScreen extends StatefulWidget {
 *      @override
 *      State<AddSaleScreen> createState() => _AddSaleScreenState();
 *    }
 * 
 *    class _AddSaleScreenState extends State<AddSaleScreen> {
 *      final _quantityController = TextEditingController();
 *      final _priceController = TextEditingController();
 * 
 *      @override
 *      Widget build(BuildContext context) {
 *        return Scaffold(
 *          appBar: AppBar(title: const Text('Record Sale')),
 *          body: Consumer2<InventoryProvider, SalesProvider>(
 *            builder: (context, inventoryProvider, salesProvider, _) {
 *              return Column(
 *                children: [
 *                  // Item selector
 *                  DropdownButton<InventoryItem>(
 *                    items: inventoryProvider.state.items
 *                        .where((item) => item.isSellable)
 *                        .map((item) => DropdownMenuItem(
 *                          value: item,
 *                          child: Text(item.name),
 *                        ))
 *                        .toList(),
 *                    onChanged: (item) {
 *                      // Update selection
 *                    },
 *                  ),
 *                  TextField(controller: _quantityController),
 *                  TextField(controller: _priceController),
 *                  ElevatedButton(
 *                    onPressed: () async {
 *                      try {
 *                        await salesProvider.recordSale(
 *                          itemId: selectedItem.id,
 *                          quantity: int.parse(_quantityController.text),
 *                          sellingPrice: double.parse(_priceController.text),
 *                          createdBy: authUser.uid,
 *                        );
 *                        
 *                        if (mounted) {
 *                          ScaffoldMessenger.of(context).showSnackBar(
 *                            const SnackBar(content: Text('Sale recorded!')),
 *                          );
 *                          Navigator.pop(context);
 *                        }
 *                      } catch (e) {
 *                        if (mounted) {
 *                          ErrorHandler.showErrorSnackBar(context, e);
 *                        }
 *                      }
 *                    },
 *                    child: const Text('Record Sale'),
 *                  ),
 *                  if (salesProvider.state.error != null)
 *                    Padding(
 *                      padding: const EdgeInsets.all(8.0),
 *                      child: Text(
 *                        'Error: ${salesProvider.state.error}',
 *                        style: const TextStyle(color: Colors.red),
 *                      ),
 *                    ),
 *                ],
 *              );
 *            },
 *          ),
 *        );
 *      }
 *    }
 * 
 * =================================================================
 * PHASE 3: CREATING NEW FEATURE SCREENS
 * =================================================================
 * 
 * For completely new screens (e.g., Analytics Dashboard), use:
 * 
 * 1. Create a new provider with state:
 * 
 *    // lib/presentation/providers/analytics/analytics_state.dart
 *    class AnalyticsState {
 *      final ProfitMetrics? metrics;
 *      final bool isLoading;
 *      final String? error;
 *      
 *      AnalyticsState({
 *        this.metrics,
 *        this.isLoading = false,
 *        this.error,
 *      });
 *    }
 * 
 *    // lib/presentation/providers/analytics/analytics_provider.dart
 *    class AnalyticsProvider extends ChangeNotifier {
 *      final CalculateProfitUseCase _usecase;
 *      
 *      AnalyticsState _state = AnalyticsState();
 *      AnalyticsState get state => _state;
 *      
 *      Future<void> loadMetrics(DateRange range) async {
 *        try {
 *          final metrics = await _usecase(shopId: shopId, dateRange: range);
 *          _state = _state.copyWith(metrics: metrics);
 *        } catch (e) {
 *          _state = _state.copyWith(error: e.toString());
 *        }
 *        notifyListeners();
 *      }
 *    }
 * 
 * 2. Use in screen:
 * 
 *    class AnalyticsScreen extends StatelessWidget {
 *      @override
 *      Widget build(BuildContext context) {
 *        return Consumer<AnalyticsProvider>(
 *          builder: (context, analytics, _) {
 *            return Column(
 *              children: [
 *                Text('Revenue: ${analytics.state.metrics?.totalRevenue}'),
 *                Text('Profit: ${analytics.state.metrics?.marginPercent}%'),
 *              ],
 *            );
 *          },
 *        );
 *      }
 *    }
 * 
 * =================================================================
 * PHASE 4: MIGRATION CHECKLIST
 * =================================================================
 * 
 * Migrate screens in this order (easier to complex):
 * 
 * ☐ inventory_screen.dart
 *   → Replace AppProvider.inventory with InventoryProvider.state.items
 *   → Replace addInventoryItem() with inventoryProvider.addItem()
 *   → Handle errors with ErrorHandler
 * 
 * ☐ sales_screen.dart
 *   → Replace AppProvider.sales with SalesProvider.state.sales
 *   → Use new AddSaleUseCase for transaction safety
 *   → Show profit margin calculations
 * 
 * ☐ statistics_screen.dart
 *   → Create AnalyticsProvider using CalculateProfitUseCase
 *   → Display KPI metrics
 *   → Add fl_chart visualizations
 * 
 * ☐ dashboard_screen.dart
 *   → Combine InventoryProvider + SalesProvider
 *   → Show low stock alerts
 *   → Display sync status from SyncQueue
 * 
 * ☐ admin_screen.dart
 *   → Keep existing role checks
 *   → Use InventoryProvider for admin operations
 * 
 * ☐ Other screens...
 * 
 * =================================================================
 * KEY DIFFERENCES FROM OLD ARCHITECTURE
 * =================================================================
 * 
 * OLD:
 *   appProvider.sales
 *   appProvider.inventory
 *   appProvider.addSale(...)
 * 
 * NEW:
 *   salesProvider.state.sales
 *   inventoryProvider.state.items
 *   salesProvider.recordSale(...) // Uses AddSaleUseCase internally
 * 
 * Benefits:
 * ✅ Type-safe state with copyWith()
 * ✅ Separated concerns (inventory vs sales vs analytics)
 * ✅ Transactional operations (inventory auto-deducted on sale)
 * ✅ Better error handling and user feedback
 * ✅ Retry logic automatically applied
 * ✅ Offline-first with proper sync
 * ✅ Testable business logic (use cases are pure)
 * ✅ Scalable feature-based structure
 * 
 * =================================================================
 * TESTING THE NEW ARCHITECTURE
 * =================================================================
 * 
 * Unit tests for use cases:
 * 
 *   test('AddSaleUseCase should deduct inventory', () async {
 *     final inventoryRepo = MockInventoryRepository();
 *     final salesRepo = MockSalesRepository();
 *     final notificationService = MockNotificationService();
 *     
 *     final usecase = AddSaleUseCase(
 *       salesRepository: salesRepo,
 *       inventoryRepository: inventoryRepo,
 *       notificationService: notificationService,
 *     );
 *     
 *     final sale = await usecase(
 *       shopId: 'shop1',
 *       itemId: 'item1',
 *       quantity: 5,
 *       sellingPrice: 100,
 *       createdBy: 'user1',
 *     );
 *     
 *     verify(inventoryRepo.updateItem(...)).called(1);
 *     expect(sale.quantity, 5);
 *   });
 * 
 * =================================================================
 */
