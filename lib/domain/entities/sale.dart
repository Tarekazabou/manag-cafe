class Sale {
  final String id;
  final String itemId;
  final String itemName;
  final int quantity;
  final double sellingPrice;
  final double totalAmount;
  final double cost;
  final double margin;
  final DateTime date;
  final String createdBy;
  final String? updatedBy;

  Sale({
    required this.id,
    this.itemId = '',
    required this.itemName,
    required this.quantity,
    required this.sellingPrice,
    this.totalAmount = 0.0,
    this.cost = 0.0,
    this.margin = 0.0,
    required this.date,
    this.createdBy = 'sys',
    this.updatedBy,
  });

  double get marginPercent =>
      totalAmount > 0 ? (margin / totalAmount) * 100 : 0;

  Sale copyWith({
    String? itemName,
    int? quantity,
    double? sellingPrice,
    String? updatedBy,
  }) =>
      Sale(
        id: id,
        itemId: itemId,
        itemName: itemName ?? this.itemName,
        quantity: quantity ?? this.quantity,
        sellingPrice: sellingPrice ?? this.sellingPrice,
        totalAmount: (quantity ?? this.quantity) * (sellingPrice ?? this.sellingPrice),
        cost: (quantity ?? this.quantity) * cost / this.quantity,
        margin: (quantity ?? this.quantity) * (sellingPrice ?? this.sellingPrice) -
            ((quantity ?? this.quantity) * cost / this.quantity),
        date: date,
        createdBy: createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemId': itemId,
        'itemName': itemName,
        'quantity': quantity,
        'sellingPrice': sellingPrice,
        'totalAmount': totalAmount,
        'cost': cost,
        'margin': margin,
        'date': date.toIso8601String(),
        'createdBy': createdBy,
        'updatedBy': updatedBy,
      };

  factory Sale.fromJson(Map<dynamic, dynamic> json) {
    final quantity = json['quantity'] is int
        ? json['quantity'] as int
        : (json['quantity'] as double?)?.toInt() ?? 0;
    final sellingPrice = json['sellingPrice'] is int
        ? (json['sellingPrice'] as int).toDouble()
        : json['sellingPrice'] as double? ?? 0.0;
    final cost = json['cost'] is int
        ? (json['cost'] as int).toDouble()
        : json['cost'] as double? ?? 0.0;

    final totalAmount = json['totalAmount'] is num
        ? (json['totalAmount'] as num).toDouble()
        : sellingPrice * quantity;
    final margin = json['margin'] is num
        ? (json['margin'] as num).toDouble()
        : (sellingPrice * quantity) - cost;

    return Sale(
      id: json['id']?.toString() ?? '',
      itemId: json['itemId']?.toString() ?? '',
      itemName: json['itemName']?.toString() ?? '',
      quantity: quantity,
      sellingPrice: sellingPrice,
      totalAmount: totalAmount,
      cost: cost,
      margin: margin,
      date: json['date'] != null
          ? DateTime.parse(json['date'].toString())
          : DateTime.now(),
      createdBy: json['createdBy']?.toString() ?? 'unknown',
      updatedBy: json['updatedBy']?.toString(),
    );
  }
}

