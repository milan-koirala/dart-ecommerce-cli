class Order {
  final String id;
  final String userId;
  final Map<String, int> items; // productId -> quantity
  final double totalCost;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalCost,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['userId'] as String,
      items: (json['items'] as Map<String, dynamic>).map((k, v) => MapEntry(k, v as int)),
      totalCost: (json['totalCost'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items,
      'totalCost': totalCost,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Order #$id | User: $userId | Created: ${createdAt.toString().substring(0, 16)} | Items: ${items.length} | Total: 💲${totalCost.toStringAsFixed(2)}';
  }
}