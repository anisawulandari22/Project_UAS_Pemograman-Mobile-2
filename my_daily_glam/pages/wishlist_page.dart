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

  String selectedMenu = "Wishlist";
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
            content: Text("Yayy! Produk berhasil dibeli dan masuk ke daftar Produk ✨"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        debugPrint("Server Error: ${postResponse.body}");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSoft,
      body: Stack(
        children: [
          Row(
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
                            const SizedBox(height: 40),
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
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 25,
                                    mainAxisSpacing: 25,
                                    childAspectRatio: 0.7, 
                                  ),
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    var item = snapshot.data![index];
                                    return _buildWishlistCard(item);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isProcessing)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildWishlistCard(dynamic item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: yellowSoft.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: item['image'] != null && item['image'].toString().isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                      child: Image.memory(
                        base64Decode(item['image']),
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      ),
                    )
                  : Icon(Icons.favorite, color: pinkPrimary.withValues(alpha: 0.2), size: 50),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? "No Name",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  "Rp ${item['price']}",
                  style: TextStyle(
                    color: pinkDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteWishlistItem(item['id'], "Produk dihapus dari wishlist"),
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text("Hapus", style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _markAsPurchased(item),
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: const Text("Dibeli", style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
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
              Text(
                "My Daily Glam",
                style: TextStyle(
                  color: pinkDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildNavMenu(Icons.home, "Beranda"),
          _buildNavMenu(Icons.auto_stories, "Jurnal"),
          _buildNavMenu(Icons.inventory_2, "Produk"),
          _buildNavMenu(Icons.favorite, "Wishlist"),
          _buildNavMenu(Icons.mood, "Mood"),
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
          leading: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: () {
            if (isSelected) return;
            setState(() => selectedMenu = title);
            
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
      color: Colors.white,
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
            Text(
              "Wishlist Saya",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: pinkDark,
              ),
            ),
            const Text(
              "Daftar produk impian yang ingin kamu beli",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () async {
            final refresh = await showDialog<bool>(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) => const AddWishlistPage(),
            );
            
            if (refresh == true) {
              setState(() {}); 
            }
          },
          icon: const Icon(Icons.add),
          label: const Text("Tambah Wishlist", style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildEmptyWishlistCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: yellowSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.favorite_border_rounded, color: yellowText, size: 40),
          ),
          const SizedBox(height: 25),
          const Text(
            "Wishlist Masih Kosong",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Yuk, mulai simpan produk impianmu sekarang!",
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
