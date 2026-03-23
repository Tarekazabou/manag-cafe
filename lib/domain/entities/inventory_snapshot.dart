class InventorySnapshot {
  final String id;
  final String itemId;
  final double quantity;
  final DateTime timestamp;
  final String timeSlot;
  final String weather;

  InventorySnapshot({
    required this.id,
    required this.itemId,
    required this.quantity,
    required this.timestamp,
    required this.timeSlot,
    required this.weather,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemId': itemId,
        'quantity': quantity,
        'timestamp': timestamp.toIso8601String(),
        'timeSlot': timeSlot,
        'weather': weather,
      };

  factory InventorySnapshot.fromJson(Map<String, dynamic> json) {
    return InventorySnapshot(
      id: json['id']?.toString() ?? '',
      itemId: json['itemId']?.toString() ?? '',
      quantity: (json['quantity'] is int
          ? (json['quantity'] as int).toDouble()
          : json['quantity'] as double?) ??
          0.0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'].toString())
          : DateTime.now(),
      timeSlot: json['timeSlot']?.toString() ?? '',
      weather: json['weather']?.toString() ?? '',
    );
  }
}
