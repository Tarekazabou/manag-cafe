import 'package:get_it/get_it.dart';
import '../../services/database_helper.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/datasources/remote_datasource.dart';
import '../../data/datasources/local_datasource.dart';
import '../../data/services/sync_queue.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../data/repositories/sales_repository_impl.dart';
import '../../data/repositories/snapshot_repository_impl.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../domain/repositories/snapshot_repository.dart';
import '../../domain/usecases/add_sale_usecase.dart';
import '../../domain/usecases/calculate_profit_usecase.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  static Future<void> setup() async {
    // Core services
    final dbHelper = DatabaseHelper.instance;
    getIt.registerSingleton<DatabaseHelper>(dbHelper);

    final connectivityService = ConnectivityService();
    connectivityService.initialize();
    getIt.registerSingleton<ConnectivityService>(connectivityService);

    // Data sources
    final remoteDataSource = RemoteDataSource();
    getIt.registerSingleton<RemoteDataSource>(remoteDataSource);

    final localDataSource = LocalDataSource(dbHelper: dbHelper);
    getIt.registerSingleton<LocalDataSource>(localDataSource);

    // Sync queue
    final syncQueue = SyncQueue(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
      connectivity: connectivityService,
    );
    getIt.registerSingleton<SyncQueue>(syncQueue);

    // Repositories
    final inventoryRepository = InventoryRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      connectivity: connectivityService,
    );
    getIt.registerSingleton<InventoryRepository>(inventoryRepository);

    final salesRepository = SalesRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      connectivity: connectivityService,
    );
    getIt.registerSingleton<SalesRepository>(salesRepository);

    final snapshotRepository = SnapshotRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      connectivity: connectivityService,
    );
    getIt.registerSingleton<SnapshotRepository>(snapshotRepository);

    // Use cases
    final calculateProfitUseCase =
        CalculateProfitUseCase(salesRepository);
    getIt.registerSingleton<CalculateProfitUseCase>(calculateProfitUseCase);

    // Note: AddSaleUseCase requires NotificationService
    // which we'll pass from the provider that uses it
  }

  static void dispose() {
    getIt<ConnectivityService>().dispose();
    getIt<SyncQueue>().dispose();
  }
}
