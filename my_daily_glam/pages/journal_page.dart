import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import '../dashboard_page.dart';
import '../exit_helper.dart'; 
import '../products/product_list_page.dart';
import 'add_journal_page.dart';
import 'wishlist_page.dart';
import 'mood_tracker_page.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final Color pinkPrimary = const Color(0xFFFF69B4);
  final Color pinkDark = const Color(0xFFD02090);
  final Color bgSoft = const Color(0xFFFFF5F7);
  final Color yellowSoft = const Color(0xFFFFF9E6);
  final Color yellowText = const Color(0xFFD4A017);

  String selectedMenu = "Jurnal";

  @override
  void initState() {
    super.initState();
    _syncChecklistFromJournals();
  }

  Future<void> _syncChecklistFromJournals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String dateId = DateTime.now().toString().split(' ')[0];

    try {
      final journalSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('journals')
          .where('dateDisplay', isGreaterThanOrEqualTo: dateId)
          .get();

      if (journalSnapshot.docs.isEmpty) return;

      Map<String, bool> updatedChecklist = {
        "Gentle Cleanser": false,
        "Hydrating Toner": false,
        "Niacinamide Serum": false,
        "Moisturizer & Sunscreen": false,
      };

      for (var doc in journalSnapshot.docs) {
        String products = doc.data()['products']?.toString() ?? "";
        if (products.contains("Cleanser")) updatedChecklist["Gentle Cleanser"] = true;
        if (products.contains("Toner")) updatedChecklist["Hydrating Toner"] = true;
        if (products.contains("Serum")) updatedChecklist["Niacinamide Serum"] = true;
        if (products.contains("Sunscreen")) updatedChecklist["Moisturizer & Sunscreen"] = true;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('moods')
          .doc(dateId)
          .set({
        'skincare_check': updatedChecklist,
        'sync_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

    } catch (e) {
      debugPrint("Gagal sinkronisasi jurnal ke dashboard: $e");
    }
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
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleSection(context),
                        const SizedBox(height: 40),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser?.uid)
                              .collection('journals')
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Center(child: Text("Terjadi kesalahan memuat data"));
                            }
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator(color: pinkPrimary));
                            }
                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 50),
                                    Icon(Icons.auto_stories, size: 80, color: pinkPrimary.withValues(alpha: 0.1)),
                                    const SizedBox(height: 20),
                                    const Text("Belum ada jurnal. Mulai catat hari ini! ✨", 
                                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                                
                                List<String> tags = data['products']
                                    .toString()
                                    .split(',')
                                    .where((e) => e.trim().isNotEmpty)
                                    .toList();

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 25),
                                  child: _buildJournalCard(
                                    title: data['title'] ?? "Tanpa Judul",
                                    date: data['dateDisplay'] ?? "",
                                    description: data['condition'] ?? "",
                                    tags: tags,
                                    isMorning: data['type'] == "Pagi",
                                  ),
                                );
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
                style: TextStyle(color: pinkDark, fontWeight: FontWeight.w900, fontSize: 18)),
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
          leading: Icon(icon, color: isSelected ? Colors.white : Colors.grey),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: () {
            if (isSelected) return;
            
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

  Widget _buildHeader() {
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
            Text("Jurnal Kecantikanku", 
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: pinkDark)),
            const Text("Pantau perjalanan perawatan kulitmu", 
              style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddJournalPage()),
            );
            _syncChecklistFromJournals();
          },
          icon: const Icon(Icons.add),
          label: const Text("Entri Baru", style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildJournalCard({
    required String title,
    required String date,
    required String description,
    required List<String> tags,
    required bool isMorning,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isMorning ? yellowSoft : const Color(0xFFE8F0FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isMorning ? Icons.wb_sunny : Icons.nightlight_round, 
              color: isMorning ? yellowText : Colors.blueAccent, 
              size: 35
            ),
          ),
          const SizedBox(width: 25),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isMorning ? yellowSoft : const Color(0xFFE8F0FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isMorning ? "PAGI" : "MALAM", 
                        style: TextStyle(
                          color: isMorning ? yellowText : Colors.blueAccent, 
                          fontSize: 10, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ),
                  ],
                ),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 12),
                Text(description, style: const TextStyle(color: Colors.black54, height: 1.5)),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: bgSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(tag, style: TextStyle(color: pinkPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
