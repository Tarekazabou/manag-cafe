class InventorySnapshot {
  final String id;
  final String itemId;
  final double quantity;
  final String timestamp;
  final String timeSlot; // Added field
  final String weather;  // Added field

  InventorySnapshot({
    required this.id,
    required this.itemId,
    required this.quantity,
    required this.timestamp,
    required this.timeSlot,
    required this.weather,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'quantity': quantity,
      'timestamp': timestamp,
      'timeSlot': timeSlot,
      'weather': weather,
    };
  }

  factory InventorySnapshot.fromJson(Map<String, dynamic> json) {
    return InventorySnapshot(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      timestamp: json['timestamp'] as String,
      timeSlot: json['timeSlot'] as String? ?? '14:00', // Default value
      weather: json['weather'] as String? ?? 'Nice',    // Default value
    );
  }
}