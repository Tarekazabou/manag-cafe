class Sale {
  final String id;
  final String itemName;
  final int quantity;
  final double sellingPrice;
  final String date;

  Sale({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.sellingPrice,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemName': itemName,
        'quantity': quantity,
        'sellingPrice': sellingPrice,
        'date': date,
      };

  factory Sale.fromJson(Map<dynamic, dynamic> json) => Sale(
        id: json['id'],
        itemName: json['itemName'],
        quantity: json['quantity'],
        sellingPrice: json['sellingPrice'].toDouble(),
        date: json['date'],
      );
}