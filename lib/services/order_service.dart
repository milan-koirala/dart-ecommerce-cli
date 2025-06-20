import 'dart:developer';
import 'package:ecommerce_cli/models/order.dart';
import 'package:ecommerce_cli/services/product_service.dart';
import 'package:ecommerce_cli/utils/file_helper.dart';

class OrderService {
  final String filePath = 'data/orders.json';
  final ProductService productService;
  List<Order> orders = [];

  OrderService(this.productService);

  Future<void> loadOrders() async {
    try {
      final jsonList = await FileHelper.readJsonFile(filePath);
      orders = jsonList.map((json) => Order.fromJson(json)).toList();
      log('Loaded ${orders.length} orders from $filePath');
    } catch (e) {
      log('Error loading orders: $e');
      print('❌ Failed to load orders: $e');
    }
  }

  Future<void> saveOrders() async {
    try {
      final jsonList = orders.map((o) => o.toJson()).toList();
      await FileHelper.writeJsonFile(filePath, jsonList);
      log('Saved ${orders.length} orders to $filePath');
    } catch (e) {
      log('Error saving orders: $e');
      print('❌ Failed to save orders: $e');
    }
  }

  Future<void> createOrder(String userId, Map<String, int> items) async {
    try {
      await productService.reduceStock(items); // Reduce stock before creating order
      double totalCost = 0;
      for (var entry in items.entries) {
        final product = productService.products.firstWhere(
          (p) => p.id == entry.key,
          orElse: () => throw Exception('Product ID ${entry.key} not found'),
        );
        totalCost += product.price * entry.value;
      }

      final order = Order(
        id: _generateId(),
        userId: userId,
        items: items,
        totalCost: totalCost,
        createdAt: DateTime.now(),
      );
      orders.add(order);
      await saveOrders();
      print('✅ $order');
      log('Created order: $order');
    } catch (e) {
      log('Error creating order: $e');
      print('❌ Failed to create order: $e');
    }
  }

  void viewOrders(String userId) {
    final userOrders = orders.where((o) => o.userId == userId).toList();
    if (userOrders.isEmpty) {
      print('⚠️ No orders found.');
      return;
    }

    print('\n📑 Order History');
    print('┌─────┬────────────────────────────┬──────────┬────────┬──────────────────┐');
    print('│ No. │ Order ID                   │ Total    │ Items  │ Created          │');
    print('├─────┼────────────────────────────┼──────────┼────────┼──────────────────┤');
    for (var i = 0; i < userOrders.length; i++) {
      final o = userOrders[i];
      final idTruncated = o.id.length > 26 ? '${o.id.substring(0, 23)}...' : o.id.padRight(26);
      final totalFormatted = o.totalCost.toStringAsFixed(2).padRight(8);
      final itemsFormatted = o.items.length.toString().padRight(6);
      final createdFormatted = o.createdAt.toString().substring(0, 16).padRight(16);
      print('│ $i${" " * (3 - i.toString().length)} │ $idTruncated │ $totalFormatted │ $itemsFormatted │ $createdFormatted │');
    }
  }

  void filterOrdersByDate(String userId, DateTime date) {
    final userOrders = orders.where((o) => o.userId == userId && o.createdAt.year == date.year && o.createdAt.month == date.month && o.createdAt.day == date.day).toList();
    if (userOrders.isEmpty) {
      print('⚠️ No orders found for ${date.toString().substring(0, 10)}.');
      return;
    }

    print('\n📑 Order History for ${date.toString().substring(0, 10)}');
    print('┌─────┬────────────────────────────┬──────────┬────────┬──────────────────┐');
    print('│ No. │ Order ID                   │ Total    │ Items  │ Created          │');
    print('├─────┼────────────────────────────┼──────────┼────────┼──────────────────┤');
    for (var i = 0; i < userOrders.length; i++) {
      final o = userOrders[i];
      final idTruncated = o.id.length > 26 ? '${o.id.substring(0, 23)}...' : o.id.padRight(26);
      final totalFormatted = o.totalCost.toStringAsFixed(2).padRight(8);
      final itemsFormatted = o.items.length.toString().padRight(6);
      final createdFormatted = o.createdAt.toString().substring(0, 16).padRight(16);
      print('│ $i${" " * (3 - i.toString().length)} │ $idTruncated │ $totalFormatted │ $itemsFormatted │ $createdFormatted │');
    }
  }

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}