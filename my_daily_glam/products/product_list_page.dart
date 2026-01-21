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

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  // --- TEMA WARNA ---
  final Color pinkPrimary = const Color(0xFFFF69B4);
  final Color pinkDark = const Color(0xFFD02090);
  final Color bgSoft = const Color(0xFFFFF5F7);
  final Color yellowSoft = const Color(0xFFFFF9E6);
  final Color yellowText = const Color(0xFFD4A017);

  String selectedMenu = "Produk";

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
            width: double.infinity,
            child: Icon(Icons.broken_image, color: yellowText),
          ),
        );
      } catch (e) {
        return Container(
          color: yellowSoft,
          width: double.infinity,
          child: Icon(Icons.broken_image, color: yellowText),
        );
      }
    }

    return Image.network(
      product.imageUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: yellowSoft,
        width: double.infinity,
        child: Icon(Icons.broken_image, color: yellowText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSoft,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleSection(context),
                        const SizedBox(height: 30),
                        _buildSearchBar(),
                        const SizedBox(height: 30),
                        _buildProductGrid(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFFFE4E9))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.face_retouching_natural, color: pinkDark, size: 32),
              const SizedBox(width: 10),
              Text("My Daily Glam",
                  style: TextStyle(
                      color: pinkDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 18)),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              children: [
                _buildNavMenu(Icons.home, "Beranda"),
                _buildNavMenu(Icons.auto_stories, "Jurnal"),
                _buildNavMenu(Icons.inventory_2, "Produk"),
                _buildNavMenu(Icons.favorite, "Wishlist"),
                _buildNavMenu(Icons.mood, "Mood"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavMenu(IconData icon, String title) {
    bool isSelected = selectedMenu == title;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? pinkPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          leading: Icon(icon, color: isSelected ? Colors.white : Colors.grey),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: () {
            if (title == selectedMenu) return;
            Widget targetPage;
            switch (title) {
              case "Beranda": targetPage = const DashboardPage(); break;
              case "Jurnal": targetPage = const JournalPage(); break;
              case "Produk": targetPage = const ProductListPage(); break;
              case "Wishlist": targetPage = const WishlistPage(); break;
              case "Mood": targetPage = const MoodPage(); break;
              default: return;
            }
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => targetPage),
              (route) => false,
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFFFE4E9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: () => ExitHelper.logout(context),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text("Keluar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: pinkPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Skincare Saya",
                style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.w900, color: pinkDark)),
            const Text("Temukan produk terbaik untuk kulitmu",
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddProductPage()),
            );
            if (result == true) {
              setState(() {}); 
            }
          },
          icon: const Icon(Icons.add),
          label: const Text("Tambah Produk", style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: pinkPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Cari produk skincare...",
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return FutureBuilder<List<Product>>(
      future: ApiService().fetchProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: pinkPrimary));
        }
        final products = snapshot.data ?? [];
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.75,
            crossAxisSpacing: 25,
            mainAxisSpacing: 25,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) => _buildProductCard(context, products[index]),
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              child: _buildProductImage(product),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: yellowSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    product.brand.toUpperCase(),
                    style: TextStyle(color: yellowText, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddProductPage(product: product),
                            ),
                          );
                          if (result == true) setState(() {});
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: pinkDark,
                          side: BorderSide(color: pinkPrimary.withValues(alpha: 0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Edit", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () async {
                        bool confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Hapus Produk"),
                            content: Text("Apakah Anda yakin ingin menghapus ${product.name}?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Batal"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ) ?? false;

                        if (confirm) {
                          bool success = await ApiService().deleteProduct(product.id);
                          if (success) {
                            setState(() {});
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Produk berhasil dihapus")),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
