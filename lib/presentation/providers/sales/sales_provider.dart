import '../../../domain/entities/sale.dart';
import 'package:flutter/material.dart';
import '../../../domain/repositories/sales_repository.dart';
import '../../../domain/repositories/inventory_repository.dart';
import '../../../domain/usecases/add_sale_usecase.dart';
import '../../../core/utils/logger.dart';
import '../../providers/sales/sales_state.dart';

class SalesProvider extends ChangeNotifier {
  final AddSaleUseCase _addSaleUseCase;
  final SalesRepository _salesRepository;
  final String _shopId;

  SalesState _state = SalesState();
  SalesState get state => _state;

  SalesProvider({
    required AddSaleUseCase addSaleUseCase,
    required SalesRepository salesRepository,
    required String shopId,
  })  : _addSaleUseCase = addSaleUseCase,
        _salesRepository = salesRepository,
        _shopId = shopId {
    _init();
  }

  Future<void> _init() async {
    await loadSales();
  }

  Future<void> loadSales() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final sales = await _salesRepository.getSales(_shopId);
      _state = _state.copyWith(
        sales: sales,
        isLoading: false,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      logger.error('Failed to load sales', error: e);
      _state = _state.copyWith(isLoading: false, error: e.toString());
    }
    notifyListeners();
  }

  Future<void> recordSale({
    required String itemId,
    required int quantity,
    required double sellingPrice,
    required String createdBy,
  }) async {
    try {
      final sale = await _addSaleUseCase(
        shopId: _shopId,
        itemId: itemId,
        quantity: quantity,
        sellingPrice: sellingPrice,
        createdBy: createdBy,
      );

      _state = _state.copyWith(
        sales: [sale, ..._state.sales],
      );
      notifyListeners();
    } catch (e) {
      logger.error('Failed to record sale', error: e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteSale(String saleId) async {
    try {
      await _salesRepository.deleteSale(_shopId, saleId);
      _state = _state.copyWith(
        sales: _state.sales.where((s) => s.id != saleId).toList(),
      );
      notifyListeners();
    } catch (e) {
      logger.error('Failed to delete sale', error: e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}


