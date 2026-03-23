class SyncOperation {
  final String id;
  final String entityId;
  final SyncOperationType type;
  final String collection;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime? syncedAt;
  final int retryCount;
  final String? error;

  SyncOperation({
    required this.id,
    required this.entityId,
    required this.type,
    required this.collection,
    required this.data,
    required this.createdAt,
    this.syncedAt,
    this.retryCount = 0,
    this.error,
  });

  bool get isSynced => syncedAt != null;
  bool get needsRetry => retryCount < 3 && !isSynced;

  SyncOperation copyWith({
    DateTime? syncedAt,
    int? retryCount,
    String? error,
  }) =>
      SyncOperation(
        id: id,
        entityId: entityId,
        type: type,
        collection: collection,
        data: data,
        createdAt: createdAt,
        syncedAt: syncedAt ?? this.syncedAt,
        retryCount: retryCount ?? this.retryCount,
        error: error,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'entityId': entityId,
        'type': type.name,
        'collection': collection,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'syncedAt': syncedAt?.toIso8601String(),
        'retryCount': retryCount,
        'error': error,
      };

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'] as String,
      entityId: json['entityId'] as String,
      type: SyncOperationType.values.byName(json['type'] as String),
      collection: json['collection'] as String,
      data: json['data'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      syncedAt: json['syncedAt'] != null
          ? DateTime.parse(json['syncedAt'] as String)
          : null,
      retryCount: json['retryCount'] as int? ?? 0,
      error: json['error'] as String?,
    );
  }
}

enum SyncOperationType { create, update, delete }

class ProfitMetrics {
  final double totalRevenue;
  final double totalCost;
  final double profit;
  final double marginPercent;
  final double avgTransactionValue;
  final int itemsSoldCount;
  final int transactionCount;
  final DateTime calculatedAt;

  ProfitMetrics({
    required this.totalRevenue,
    required this.totalCost,
    required this.profit,
    required this.marginPercent,
    required this.avgTransactionValue,
    required this.itemsSoldCount,
    required this.transactionCount,
    DateTime? calculatedAt,
  }) : calculatedAt = calculatedAt ?? DateTime.now();
}
