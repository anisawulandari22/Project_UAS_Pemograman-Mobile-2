import 'dart:convert';
import 'package:flutter/material.dart';
import '../exit_helper.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import '../dashboard_page.dart';
import '../pages/journal_page.dart';
import '../pages/mood_tracker_page.dart';
import '../pages/wishlist_page.dart';
import 'add_product_page.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final Color pinkPrimary = const Color(0xFFFF69B4);
  final Color pinkDark = const Color(0xFFD02090);
  final Color bgSoft = const Color(0xFFFFF5F7);
  final Color yellowSoft = const Color(0xFFFFF9E6);
  final Color yellowText = const Color(0xFFD4A017);

  int _currentIndex = 2;

  Widget _buildProductImage(Product product) {
    if (product.imageUrl.isEmpty) {
      return Container(
        color: yellowSoft,
        width: double.infinity,
        child: Icon(Icons.image_not_supported, color: yellowText),
      );
    }

    if (!product.imageUrl.startsWith('http')) {
      try {
        return Image.memory(
          base64Decode(product.imageUrl),
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: yellowSoft,
            child: Icon(Icons.broken_image, color: yellowText),
          ),
        );
      } catch (e) {
        return Container(color: yellowSoft, child: Icon(Icons.broken_image, color: yellowText));
      }
    }

    return Image.network(
      product.imageUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(color: yellowSoft, child: Icon(Icons.broken_image, color: yellowText)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSoft,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("My Daily Glam", style: TextStyle(color: pinkDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () => ExitHelper.logout(context), icon: Icon(Icons.logout, color: pinkPrimary)),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFFFE4E9), height: 1),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        color: pinkPrimary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleSection(context),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 20),
              _buildProductGrid(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Skincare Saya", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: pinkDark)),
            const Text("Kelola produk kecantikanmu", style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
        FloatingActionButton.small(
          onPressed: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductPage()));
            if (result == true) setState(() {});
          },
          backgroundColor: pinkPrimary,
          elevation: 2,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Cari skincare...",
          hintStyle: TextStyle(fontSize: 14),
          border: InputBorder.none,
          icon: Icon(Icons.search, size: 20, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return FutureBuilder<List<Product>>(
      future: ApiService().fetchProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator()));
        }
        final products = snapshot.data ?? [];
        if (products.isEmpty) return const Center(child: Text("Belum ada produk."));
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) => _buildProductCard(context, products[index]),
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(product: product))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: product.id,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: _buildProductImage(product),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.brand.toUpperCase(), style: TextStyle(color: yellowText, fontSize: 9, fontWeight: FontWeight.bold), maxLines: 1),
                  const SizedBox(height: 2),
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddProductPage(product: product)));
                          if (result == true) setState(() {});
                        },
                        child: Text("Edit", style: TextStyle(color: pinkDark, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: () => _showDeleteDialog(product),
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Product product) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Produk?"),
        content: Text("Apakah kamu yakin ingin menghapus ${product.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      bool success = await ApiService().deleteProduct(product.id);
      if (success) setState(() {});
    }
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: pinkPrimary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == _currentIndex) return;
        Widget page;
        switch (index) {
          case 0: page = const DashboardPage(); break;
          case 1: page = const JournalPage(); break;
          case 2: page = const ProductListPage(); break;
          case 3: page = const WishlistPage(); break;
          case 4: page = const MoodPage(); break;
          default: return;
        }
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Beranda"),
        BottomNavigationBarItem(icon: Icon(Icons.auto_stories_outlined), activeIcon: Icon(Icons.auto_stories), label: "Jurnal"),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: "Produk"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), activeIcon: Icon(Icons.favorite), label: "Wishlist"),
        BottomNavigationBarItem(icon: Icon(Icons.mood_outlined), activeIcon: Icon(Icons.mood), label: "Mood"),
      ],
    );
  }
}
