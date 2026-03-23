class InventoryItem {
  final String id;
  final String name;
  final double quantity;
  final double buyPrice;
  final double sellPrice;
  final double lowStockThreshold;
  final bool isSellable;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;

  InventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.buyPrice,
    required this.sellPrice,
    required this.lowStockThreshold,
    this.isSellable = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.createdBy,
    this.updatedBy,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  InventoryItem copyWith({
    String? name,
    double? quantity,
    double? buyPrice,
    double? sellPrice,
    double? lowStockThreshold,
    bool? isSellable,
    DateTime? updatedAt,
    String? updatedBy,
  }) =>
      InventoryItem(
        id: id,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        buyPrice: buyPrice ?? this.buyPrice,
        sellPrice: sellPrice ?? this.sellPrice,
        lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
        isSellable: isSellable ?? this.isSellable,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
        createdBy: createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'buyPrice': buyPrice,
        'sellPrice': sellPrice,
        'lowStockThreshold': lowStockThreshold,
        'isSellable': isSellable,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'createdBy': createdBy,
        'updatedBy': updatedBy,
      };

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      quantity: (json['quantity'] is int
          ? (json['quantity'] as int).toDouble()
          : json['quantity'] as double?) ??
          0.0,
      buyPrice: (json['buyPrice'] is int
          ? (json['buyPrice'] as int).toDouble()
          : json['buyPrice'] as double?) ??
          0.0,
      sellPrice: (json['sellPrice'] is int
          ? (json['sellPrice'] as int).toDouble()
          : json['sellPrice'] as double?) ??
          0.0,
      lowStockThreshold: (json['lowStockThreshold'] is int
          ? (json['lowStockThreshold'] as int).toDouble()
          : json['lowStockThreshold'] as double?) ??
          0.0,
      isSellable: (json['isSellable'] is int
          ? json['isSellable'] == 1
          : json['isSellable'] as bool?) ??
          true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      createdBy: json['createdBy']?.toString() ?? 'unknown',
      updatedBy: json['updatedBy']?.toString(),
    );
  }
}
