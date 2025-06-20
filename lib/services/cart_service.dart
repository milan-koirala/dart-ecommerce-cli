import 'dart:developer';
import 'package:ecommerce_cli/models/cart.dart';
import 'package:ecommerce_cli/services/product_service.dart';

class CartService {
  final ProductService productService;
  final Map<String, Cart> _carts = {}; // userId -> Cart

  CartService(this.productService);

  Future<void> addToCart(String userId, String productId, int quantity) async {
    try {
      final product = productService.products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product ID $productId not found'),
      );
      if (product.stock < quantity) {
        throw Exception('Insufficient stock for ${product.name}');
      }

      _carts.putIfAbsent(userId, () => Cart(userId: userId, items: {}));
      _carts[userId]!.items.update(productId, (value) => value + quantity, ifAbsent: () => quantity);
      print('✅ Added $quantity ${product.name}(s) to cart');
      log('Added to cart: user=$userId, product=$productId, quantity=$quantity');
    } catch (e) {
      log('Error adding to cart: $e');
      print('❌ Failed to add to cart: $e');
    }
  }

  Future<void> removeFromCart(String userId, int index) async {
    try {
      if (!_carts.containsKey(userId) || _carts[userId]!.items.isEmpty) {
        throw Exception('Cart is empty');
      }
      final items = _carts[userId]!.items.entries.toList();
      if (index < 0 || index >= items.length) {
        throw Exception('Invalid item index');
      }
      final productId = items[index].key;
      final product = productService.products.firstWhere((p) => p.id == productId);
      _carts[userId]!.items.remove(productId);
      print('✅ Removed ${product.name} from cart');
      log('Removed from cart: user=$userId, product=$productId');
    } catch (e) {
      log('Error removing from cart: $e');
      print('❌ Failed to remove from cart: $e');
    }
  }

  void viewCart(String userId) {
    if (!_carts.containsKey(userId) || _carts[userId]!.items.isEmpty) {
      print('⚠️ Your cart is empty.');
      return;
    }

    print('\n🛒 Your Cart');
    print('┌─────┬────────────────────────────┬──────────┬────────┐');
    print('│ No. │ Product                    │ Price    │ Qty    │');
    print('├─────┼────────────────────────────┼──────────┼────────┤');
    final items = _carts[userId]!.items.entries.toList();
    for (var i = 0; i < items.length; i++) {
      final product = productService.products.firstWhere((p) => p.id == items[i].key);
      final nameTruncated = product.name.length > 26 ? '${product.name.substring(0, 23)}...' : product.name.padRight(26);
      final priceFormatted = product.price.toStringAsFixed(2).padRight(8);
      final qtyFormatted = items[i].value.toString().padRight(6);
      print('│ $i${" " * (3 - i.toString().length)} │ $nameTruncated │ $priceFormatted │ $qtyFormatted │');
    }
    final total = _carts[userId]!.calculateTotal(productService.products);
    print('└─────┴────────────────────────────┴──────────┴────────┘');
    print('Total: 💲${total.toStringAsFixed(2)}');
  }

  bool hasCart(String userId) {
    return _carts.containsKey(userId) && _carts[userId]!.items.isNotEmpty;
  }

  Map<String, int> getCart(String userId) {
    return _carts[userId]?.items ?? {};
  }

  void clearCart(String userId) {
    _carts.remove(userId);
    log('Cleared cart for user=$userId');
  }
}