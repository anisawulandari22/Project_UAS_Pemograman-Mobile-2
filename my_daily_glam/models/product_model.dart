import 'dart:convert';
import 'dart:typed_data';

class Product {
  final String id;
  final String name;
  final String brand;
  final String imageUrl;
  final String category;
  final int price;          
  final String usageTime; 
  final String description;

  Product({
    required this.id, 
    required this.name, 
    required this.brand, 
    required this.imageUrl, 
    required this.category,
    required this.price,
    required this.usageTime,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? '',
      price: json['price'] is int ? json['price'] : int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      usageTime: json['usage_time'] ?? '',
      description: json['description'] ?? '',
    );
  }

  bool get isBase64 => imageUrl.isNotEmpty && !imageUrl.startsWith('http');

  Uint8List? get imageBytes {
    try {
      if (isBase64) {
        return base64Decode(imageUrl);
      }
    } catch (e) {
      return null; 
    }
    return null;
  }
}
