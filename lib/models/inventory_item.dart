class InventoryItem {
  final String id;
  final String name;
  final double quantity;
  final double buyPrice;
  final double sellPrice;
  final double lowStockThreshold;
  final bool isSellable; // New field to indicate if the item is directly sold

  InventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.buyPrice,
    required this.sellPrice,
    required this.lowStockThreshold,
    this.isSellable = true, // Default to true for existing items
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'lowStockThreshold': lowStockThreshold,
      'isSellable': isSellable ? 1 : 0, // Convert bool to int for SQLite
    };
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    final double fallbackUnitCost = (json['unitCost'] is int
        ? (json['unitCost'] as int).toDouble()
        : json['unitCost'] as double?) ?? 0.0;

    return InventoryItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      quantity: (json['quantity'] is int
          ? (json['quantity'] as int).toDouble()
          : json['quantity'] as double?) ?? 0.0,
      buyPrice: (json['buyPrice'] is int
          ? (json['buyPrice'] as int).toDouble()
          : json['buyPrice'] as double?) ?? fallbackUnitCost,
      sellPrice: (json['sellPrice'] is int
          ? (json['sellPrice'] as int).toDouble()
          : json['sellPrice'] as double?) ?? (fallbackUnitCost * 2),
      lowStockThreshold: (json['lowStockThreshold'] is int
          ? (json['lowStockThreshold'] as int).toDouble()
          : json['lowStockThreshold'] as double?) ?? 0.0,
      isSellable: (json['isSellable'] is int
          ? json['isSellable'] == 1
          : json['isSellable'] as bool?) ?? true, // Convert int to bool, with default
    );
  }
}