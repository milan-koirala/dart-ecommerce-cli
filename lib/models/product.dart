class Product {
  final String id;
  String name;
  double price;
  int stock;
  String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.category = '',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      category: json['category'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'category': category,
    };
  }

  @override
  String toString() {
    final categoryDisplay = category.isNotEmpty ? ' | Category: $category' : '';
    return '$name | 💲$price | Stock: $stock$categoryDisplay';
  }
}