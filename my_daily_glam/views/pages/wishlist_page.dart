import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../exit_helper.dart';
import 'add_wishlist_page.dart';
import '../dashboard_page.dart';
import 'journal_page.dart';
import '../products/product_list_page.dart';
import 'mood_tracker_page.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final Color pinkPrimary = const Color(0xFFFF69B4);
  final Color pinkDark = const Color(0xFFD02090);
  final Color bgSoft = const Color(0xFFFFF5F7);
  final Color yellowSoft = const Color(0xFFFFF9E6);
  final Color yellowText = const Color(0xFFD4A017);

  int _selectedIndex = 3;
  bool _isProcessing = false;

  Future<List<dynamic>> _fetchWishlist() async {
    try {
      final response = await http.get(Uri.parse("https://6944c4267dd335f4c3612634.mockapi.io/wishlist"));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint("Error fetching: $e");
    }
    return [];
  }

  Future<void> _markAsPurchased(dynamic item) async {
    setState(() => _isProcessing = true);
    try {
      final postResponse = await http.post(
        Uri.parse("https://6944c4267dd335f4c3612634.mockapi.io/products"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": item['name'],
          "price": item['price'], 
          "image_url": item['image'],
          "brand": "Wishlist Item", 
          "category": "Lainnya",    
          "usage_time": "Pagi & Malam",
          "description": "Produk dibeli dari wishlist",
          "createdAt": DateTime.now().toIso8601String(),
        }),
      );

      if (postResponse.statusCode == 201) {
        await http.delete(
          Uri.parse("https://6944c4267dd335f4c3612634.mockapi.io/wishlist/${item['id']}"),
        );
        setState(() {}); 
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Yayy! Produk berhasil dibeli ✨"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error moving to product: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _deleteWishlistItem(String id, String snackbarMessage) async {
    try {
      final response = await http.delete(
        Uri.parse("https://6944c4267dd335f4c3612634.mockapi.io/wishlist/$id"),
      );
      if (response.statusCode == 200) {
        setState(() {}); 
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(snackbarMessage), backgroundColor: pinkDark),
        );
      }
    } catch (e) {
      debugPrint("Error deleting: $e");
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    
    Widget targetPage;
    switch (index) {
      case 0: targetPage = const DashboardPage(); break;
      case 1: targetPage = const JournalPage(); break;
      case 2: targetPage = const ProductListPage(); break;
      case 3: targetPage = const WishlistPage(); break;
      case 4: targetPage = const MoodPage(); break;
      default: return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => targetPage),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSoft,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("My Daily Glam", 
          style: TextStyle(color: pinkDark, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: pinkDark),
            onPressed: () => ExitHelper.logout(context),
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(context),
                const SizedBox(height: 25),
                FutureBuilder<List<dynamic>>(
                  future: _fetchWishlist(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(50.0),
                        child: CircularProgressIndicator(),
                      ));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyWishlistCard();
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.65, 
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return _buildWishlistCard(snapshot.data![index]);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final refresh = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) => const AddWishlistPage(),
          );
          if (refresh == true) setState(() {});
        },
        backgroundColor: pinkPrimary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: pinkPrimary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.auto_stories), label: "Jurnal"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: "Produk"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Wishlist"),
          BottomNavigationBarItem(icon: Icon(Icons.mood), label: "Mood"),
        ],
      ),
    );
  }

  Widget _buildWishlistCard(dynamic item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: yellowSoft.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: item['image'] != null && item['image'].toString().isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.memory(
                        base64Decode(item['image']),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.favorite, color: pinkPrimary.withOpacity(0.2), size: 40),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? "No Name",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Rp ${item['price']}",
                    style: TextStyle(color: pinkDark, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _markAsPurchased(item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 30),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Dibeli", style: TextStyle(fontSize: 11)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _deleteWishlistItem(item['id'], "Dihapus"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 30),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Hapus", style: TextStyle(fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Wishlist Saya",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: pinkDark),
        ),
        const Text(
          "Daftar produk impian kamu",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildEmptyWishlistCard() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          Icon(Icons.favorite_border_rounded, color: yellowText, size: 60),
          const SizedBox(height: 20),
          const Text("Wishlist Masih Kosong", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text("Yuk, simpan produk impianmu!", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
