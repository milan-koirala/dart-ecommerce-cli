// lib/models/product.dart
import 'dart:convert';

class ProductVariant {
  String id;
  String size;
  String color;
  double price;
  int stock;

  ProductVariant({
    required this.id,
    required this.size,
    required this.color,
    required this.price,
    required this.stock,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'size': size,
        'color': color,
        'price': price,
        'stock': stock,
      };

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
        id: json['id'],
        size: json['size'],
        color: json['color'],
        price: json['price'].toDouble(),
        stock: json['stock'],
      );
}

class Review {
  String id;
  String userId;
  int rating;
  String comment;
  DateTime date;

  Review({
    required this.id,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'rating': rating,
        'comment': comment,
        'date': date.toIso8601String(),
      };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'],
        userId: json['userId'],
        rating: json['rating'],
        comment: json['comment'],
        date: DateTime.parse(json['date']),
      );
}

class Product {
  String id;
  String name;
  List<ProductVariant> variants;
  String category;
  List<Review> reviews;
  int lowStockThreshold;

  Product({
    required this.id,
    required this.name,
    required this.variants,
    required this.category,
    this.reviews = const [],
    this.lowStockThreshold = 5,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'variants': variants.map((v) => v.toJson()).toList(),
        'category': category,
        'reviews': reviews.map((r) => r.toJson()).toList(),
        'lowStockThreshold': lowStockThreshold,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        variants: (json['variants'] as List)
            .map((v) => ProductVariant.fromJson(v))
            .toList(),
        category: json['category'],
        reviews: (json['reviews'] as List? ?? [])
            .map((r) => Review.fromJson(r))
            .toList(),
        lowStockThreshold: json['lowStockThreshold'] ?? 5,
      );
}