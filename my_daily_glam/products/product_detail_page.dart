import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: product.id,
              child: Image.network(product.imageUrl, width: double.infinity, height: 300, fit: BoxFit.cover),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink)),
                  Text(product.brand, style: TextStyle(fontSize: 18, color: Colors.grey)),
                  Divider(height: 30),
                  Text("Kategori: ${product.category}", style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 10),
                  Text("Deskripsi Produk:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Produk skincare berkualitas untuk menjaga kesehatan kulit Anda setiap hari."),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () { /* Logika tambah ke wishlist di Malam hari */ },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, minimumSize: Size(double.infinity, 50)),
                    child: Text("Tambah ke Wishlist", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
