// import 'dart:math';
import '../models/product.dart';
import '../utils/file_helper.dart';

class ProductService {
  final String filePath = 'data/products.json';
  List<Product> products = [];

  Future<void> loadProducts() async {
    final jsonList = await FileHelper.readJsonFile(filePath);
    products = jsonList.map((json) => Product.fromJson(json)).toList();
  }

  Future<void> saveProducts() async {
    final jsonList = products.map((p) => p.toJson()).toList();
    await FileHelper.writeJsonFile(filePath, jsonList);
  }

  Future<void> addProduct(String name, double price, int stock) async {
    final product = Product(
      id: _generateId(),
      name: name,
      price: price,
      stock: stock,
    );
    products.add(product);
    await saveProducts();
    print('✅ Product added: $product');
  }

  void listProducts() {
    if (products.isEmpty) {
      print('⚠️ No products found.');
      return;
    }
    for (var i = 0; i < products.length; i++) {
      print('${i + 1}. ${products[i]}');
    }
  }

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}
