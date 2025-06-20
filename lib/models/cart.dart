import 'package:ecommerce_cli/models/product.dart';

class Cart {
  final String userId;
  final Map<String, int> items; // productId -> quantity

  Cart({
    required this.userId,
    required this.items,
  });

  double calculateTotal(List<Product> products) {
    double total = 0;
    for (var entry in items.entries) {
      final product = products.firstWhere((p) => p.id == entry.key);
      total += product.price * entry.value;
    }
    return total;
  }
}