import 'dart:developer';
import 'package:ecommerce_cli/models/purchase_order.dart';
import 'package:ecommerce_cli/services/product_service.dart';
import 'package:ecommerce_cli/utils/file_helper.dart';

class PurchaseOrderService {
  final String filePath = 'data/purchase_orders.json';
  final ProductService productService;
  List<PurchaseOrder> purchaseOrders = [];

  PurchaseOrderService(this.productService);

  Future<void> loadPurchaseOrders() async {
    try {
      final jsonList = await FileHelper.readJsonFile(filePath);
      purchaseOrders = jsonList.map((json) => PurchaseOrder.fromJson(json)).toList();
      log('Loaded ${purchaseOrders.length} purchase orders from $filePath');
    } catch (e) {
      log('Error loading purchase orders: $e');
      print('❌ Failed to load purchase orders: $e');
    }
  }

  Future<void> savePurchaseOrders() async {
    try {
      final jsonList = purchaseOrders.map((po) => po.toJson()).toList();
      await FileHelper.writeJsonFile(filePath, jsonList);
      log('Saved ${purchaseOrders.length} purchase orders to $filePath');
    } catch (e) {
      log('Error saving purchase orders: $e');
      print('❌ Failed to save purchase orders: $e');
    }
  }

  Future<void> createPurchaseOrder(Map<String, int> items) async {
    try {
      double totalCost = 0;
      for (var entry in items.entries) {
        final product = productService.products.firstWhere(
          (p) => p.id == entry.key,
          orElse: () => throw Exception('Product ID ${entry.key} not found'),
        );
        totalCost += product.price * entry.value;
      }

      final purchaseOrder = PurchaseOrder(
        id: _generateId(),
        createdAt: DateTime.now(),
        items: items,
        totalCost: totalCost,
      );
      purchaseOrders.add(purchaseOrder);
      await savePurchaseOrders();
      print('✅ $purchaseOrder');
      log('Created purchase order: $purchaseOrder');
    } catch (e) {
      log('Error creating purchase order: $e');
      print('❌ Failed to create purchase order: $e');
    }
  }

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}