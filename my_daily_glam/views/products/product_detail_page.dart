import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final Color pinkPrimary = const Color(0xFFFF69B4);
    final Color pinkDark = const Color(0xFFD02090);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      appBar: AppBar(
        title: const Text("Detail Produk", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: pinkDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: product.id,
              child: Container(
                width: double.infinity,
                height: 350,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: _buildDetailImage(product.imageUrl),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.brand.toUpperCase(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: pinkPrimary, letterSpacing: 1.1)),
                  const SizedBox(height: 8),
                  Text(product.name, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: pinkDark)),
                  const SizedBox(height: 15),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: pinkPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(product.category, style: TextStyle(color: pinkDark, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  
                  const Divider(height: 40),
                  
                  const Text("Deskripsi Produk", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    product.description.isEmpty 
                      ? "Produk skincare berkualitas untuk menjaga kesehatan kulit Anda setiap hari." 
                      : product.description,
                    style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ditambahkan ke Wishlist ✨")));
                    },
                    icon: const Icon(Icons.favorite_border, color: Colors.white),
                    label: const Text("Tambah ke Wishlist", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pinkPrimary,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailImage(String url) {
    if (url.isEmpty) return const Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
    
    if (url.startsWith('http')) {
      return Image.network(url, fit: BoxFit.contain);
    } else {
      try {
        return Image.memory(base64Decode(url), fit: BoxFit.contain);
      } catch (e) {
        return const Icon(Icons.broken_image, size: 100);
      }
    }
  }
}
