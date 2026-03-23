import 'package:flutter/material.dart';
import '../../../domain/repositories/inventory_repository.dart';
import '../../../core/utils/logger.dart';
import 'inventory_state.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryRepository _repository;
  final String _shopId;

  InventoryState _state = InventoryState();
  InventoryState get state => _state;

  InventoryProvider({
    required InventoryRepository repository,
    required String shopId,
  })  : _repository = repository,
        _shopId = shopId {
    _init();
  }

  Future<void> _init() async {
    await loadInventory();
  }

  Future<void> loadInventory() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final items = await _repository.getInventoryItems(_shopId);
      _state = _state.copyWith(
        items: items,
        isLoading: false,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      logger.error('Failed to load inventory', error: e);
      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
    notifyListeners();
  }

  Future<void> addItem(InventoryItem item) async {
    try {
      await _repository.addItem(_shopId, item);
      _state = _state.copyWith(
        items: [..._state.items, item],
      );
      notifyListeners();
    } catch (e) {
      logger.error('Failed to add inventory item', error: e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateItem(InventoryItem item) async {
    try {
      await _repository.updateItem(_shopId, item);
      final index = _state.items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        final updatedItems = [..._state.items];
        updatedItems[index] = item;
        _state = _state.copyWith(items: updatedItems);
        notifyListeners();
      }
    } catch (e) {
      logger.error('Failed to update inventory item', error: e);
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await _repository.deleteItem(_shopId, itemId);
      _state = _state.copyWith(
        items: _state.items
            .where((item) => item.id != itemId)
            .toList(),
      );
      notifyListeners();
    } catch (e) {
      logger.error('Failed to delete inventory item', error: e);
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

import '../../../domain/entities/inventory_item.dart';
