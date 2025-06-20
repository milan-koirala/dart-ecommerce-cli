class PurchaseOrder {
  final String id;
  final DateTime createdAt;
  final Map<String, int> items; // productId -> quantity
  final double totalCost;

  PurchaseOrder({
    required this.id,
    required this.createdAt,
    required this.items,
    required this.totalCost,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      items: (json['items'] as Map<String, dynamic>).map((k, v) => MapEntry(k, v as int)),
      totalCost: (json['totalCost'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'items': items,
      'totalCost': totalCost,
    };
  }

  @override
  String toString() {
    return 'Purchase Order #$id | Created: ${createdAt.toString().substring(0, 16)} | Items: ${items.length} | Total: 💲${totalCost.toStringAsFixed(2)}';
  }
}