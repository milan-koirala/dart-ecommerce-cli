import 'dart:developer';
import '../models/product.dart';
import '../utils/file_helper.dart';

class ProductService {
  final String filePath = 'data/products.json';
  List<Product> products = [];

  Future<void> loadProducts() async {
    try {
      final jsonList = await FileHelper.readJsonFile(filePath);
      products = jsonList.map((json) => Product.fromJson(json)).toList();
      log('Loaded ${products.length} products from $filePath');
    } catch (e) {
      log('Error loading products: $e');
      print('❌ Failed to load products: $e');
    }
  }

  Future<void> saveProducts() async {
    try {
      final jsonList = products.map((p) => p.toJson()).toList();
      await FileHelper.writeJsonFile(filePath, jsonList);
      log('Saved ${products.length} products to $filePath');
    } catch (e) {
      log('Error saving products: $e');
      print('❌ Failed to save products: $e');
    }
  }

  Future<void> addProduct(String name, double price, int stock, String category) async {
    try {
      final product = Product(
        id: _generateId(),
        name: name,
        price: price,
        stock: stock,
        category: category,
      );
      products.add(product);
      await saveProducts();
      print('✅ Product added: $product');
      log('Added product: $product');
    } catch (e) {
      log('Error adding product: $e');
      print('❌ Failed to add product: $e');
    }
  }

  Future<void> updateProduct(int index, String name, double price, int stock, String category) async {
    try {
      if (index < 0 || index >= products.length) {
        throw Exception('Invalid product index');
      }
      final oldProduct = products[index];
      products[index] = Product(
        id: oldProduct.id,
        name: name,
        price: price,
        stock: stock,
        category: category,
      );
      await saveProducts();
      print('✅ Product updated: ${products[index]}');
      log('Updated product: ${products[index]}');
    } catch (e) {
      log('Error updating product: $e');
      print('❌ Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(int index) async {
    try {
      if (index < 0 || index >= products.length) {
        throw Exception('Invalid product index');
      }
      final product = products.removeAt(index);
      await saveProducts();
      print('✅ Product deleted: $product');
      log('Deleted product: $product');
    } catch (e) {
      log('Error deleting product: $e');
      print('❌ Failed to delete product: $e');
    }
  }

  Future<void> updateStock(Map<String, int> items) async {
    try {
      for (var entry in items.entries) {
        final productId = entry.key;
        final quantity = entry.value;
        final index = products.indexWhere((p) => p.id == productId);
        if (index == -1) {
          log('Product not found for ID: $productId');
          continue;
        }
        products[index].stock += quantity;
      }
      await saveProducts();
      log('Updated stock for ${items.length} products');
    } catch (e) {
      log('Error updating stock: $e');
      print('❌ Failed to update stock: $e');
    }
  }

  Future<void> reduceStock(Map<String, int> items) async {
    try {
      for (var entry in items.entries) {
        final productId = entry.key;
        final quantity = entry.value;
        final index = products.indexWhere((p) => p.id == productId);
        if (index == -1) {
          throw Exception('Product ID $productId not found');
        }
        if (products[index].stock < quantity) {
          throw Exception('Insufficient stock for ${products[index].name}');
        }
        products[index].stock -= quantity;
      }
      await saveProducts();
      log('Reduced stock for ${items.length} products');
    } catch (e) {
      log('Error reducing stock: $e');
      throw e;
    }
  }

  void listProducts() {
    if (products.isEmpty) {
      print('⚠️ No products found.');
      return;
    }
    print('\n📋 Product List');
    print(_formatTableHeader());
    for (var i = 0; i < products.length; i++) {
      final p = products[i];
      print(_formatTableRow(i + 1, p.name, p.price, p.stock, p.category));
    }
  }

  void searchProducts(String query) {
    final filtered = products
        .asMap()
        .entries
        .where((entry) => entry.value.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (filtered.isEmpty) {
      print('⚠️ No products found matching "$query".');
      return;
    }

    print('\n🔍 Search Results for "$query"');
    print(_formatTableHeader());
    for (var entry in filtered) {
      final i = entry.key;
      final p = entry.value;
      print(_formatTableRow(i + 1, p.name, p.price, p.stock, p.category));
    }
  }

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  String _formatTableHeader() {
    return '┌─────┬────────────────────────────┬──────────┬───────┬────────────────┐\n'
        '│ No. │ Name                       │ Price    │ Stock │ Category       │\n'
        '├─────┼────────────────────────────┼──────────┼───────┼────────────────┤';
  }

  String _formatTableRow(int number, String name, double price, int stock, String category) {
    final nameTruncated = name.length > 26 ? '${name.substring(0, 23)}...' : name.padRight(26);
    final priceFormatted = price.toStringAsFixed(2).padRight(8);
    final stockFormatted = stock.toString().padRight(5);
    final categoryTruncated = category.length > 14 ? '${category.substring(0, 11)}...' : category.padRight(14);
    return '│ $number${" " * (3 - number.toString().length)} │ $nameTruncated │ $priceFormatted │ $stockFormatted │ $categoryTruncated │';
  }
}