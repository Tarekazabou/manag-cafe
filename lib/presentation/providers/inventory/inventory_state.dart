class InventoryState {
  final List<InventoryItem> items;
  final bool isLoading;
  final String? error;
  final DateTime? lastSyncTime;

  InventoryState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.lastSyncTime,
  });

  InventoryState copyWith({
    List<InventoryItem>? items,
    bool? isLoading,
    String? error,
    DateTime? lastSyncTime,
  }) =>
      InventoryState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      );
}

import '../../domain/entities/inventory_item.dart';
