// lib/utils/csv_helper.dart
import 'dart:io';
import 'package:csv/csv.dart';
import '../models/product.dart';

class CsvHelper {
  Future<void> exportProducts(List<Product> products, String filePath) async {
    final rows = [
      ['ID', 'Name', 'Size', 'Color', 'Price', 'Stock', 'Category'],
      ...products.expand((p) => p.variants.map((v) => [
            p.id,
            p.name,
            v.size,
            v.color,
            v.price.toString(),
            v.stock.toString(),
            p.category,
          ])),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    await File(filePath).writeAsString(csv);
    print('✅ Products exported to $filePath');
  }

  Future<List<Product>> importProducts(String filePath) async {
    final file = await File(filePath).readAsString();
    final rows = const CsvToListConverter().convert(file).skip(1);
    final products = <String, Product>{};
    for (var row in rows) {
      final id = row[0].toString();
      if (!products.containsKey(id)) {
        products[id] = Product(
          id: id,
          name: row[1],
          variants: [],
          category: row[6],
        );
      }
      products[id]!.variants.add(ProductVariant(
        id: Random().nextInt(1000000).toString(),
        size: row[2],
        color: row[3],
        price: double.parse(row[4]),
        stock: int.parse(row[5]),
      ));
    }
    return products.values.toList();
  }
}