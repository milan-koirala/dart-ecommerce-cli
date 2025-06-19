import 'dart:io';
import 'package:ecommerce_cli/services/product_service.dart';

void main() async {
  final productService = ProductService();
  await productService.loadProducts();

  while (true) {
    print('\n🛍️ Milon\'s Dart E-Commerce CLI');
    print('1. List Products');
    print('2. Add Product');
    print('3. Exit');
    stdout.write('Enter choice: ');
    final input = stdin.readLineSync();

    switch (input) {
      case '1':
        productService.listProducts();
        break;
      case '2':
        stdout.write('Enter product name: ');
        final name = stdin.readLineSync() ?? '';
        stdout.write('Enter price: ');
        final price = double.tryParse(stdin.readLineSync() ?? '0') ?? 0;
        stdout.write('Enter stock: ');
        final stock = int.tryParse(stdin.readLineSync() ?? '0') ?? 0;
        await productService.addProduct(name, price, stock);
        break;
      case '3':
        print('👋 Exiting...');
        return;
      default:
        print('❌ Invalid choice.');
    }
  }
}
