import 'package:flutter/material.dart';

class Product {
  final String name;
  final double price;
  final List<String> images;
  final String category;
  final int stockQuantity;
  final String description;

  Product({
    required this.name,
    required this.price,
    required this.images,
    required this.category,
    required this.stockQuantity,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] ?? 'Unknown',
      price: json['price'] ?? 0.0,
      images: List<String>.from(json['photos'] ?? []),
      category: json['category'] ?? 'No category',
      stockQuantity: json['stockQuantity'] ?? 0,
      description: json['description'] ?? 'No description',
    );
  }
}

class ProductPage extends StatelessWidget {
  final Product product;

  const ProductPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(product.images[0]), // Display first image
            const SizedBox(height: 10),
            Text(
              product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "\$${product.price}",
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
            const SizedBox(height: 10),
            Text(
              "Category: ${product.category}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              "Stock Quantity: ${product.stockQuantity}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              "Description:",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              product.description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
