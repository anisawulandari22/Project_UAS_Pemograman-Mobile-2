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

  int _selectedIndex = 1;

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
        centerTitle: false,
        title: Text("My Daily Glam", 
          style: TextStyle(color: pinkDark, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: pinkDark),
            onPressed: () => ExitHelper.logout(context),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleSection(context),
              const SizedBox(height: 25),
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
                          Icon(Icons.auto_stories, size: 80, color: pinkPrimary.withOpacity(0.1)),
                          const SizedBox(height: 20),
                          const Text("Belum ada jurnal. ✨", 
                            style: TextStyle(color: Colors.grey, fontSize: 14)),
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
                        padding: const EdgeInsets.only(bottom: 20),
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
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: pinkPrimary,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddJournalPage()),
          );
          _syncChecklistFromJournals();
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: pinkPrimary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
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

  Widget _buildTitleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Jurnal Kecantikanku", 
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: pinkDark)),
        const Text("Pantau perjalanan perawatan kulitmu", 
          style: TextStyle(color: Colors.grey, fontSize: 14)),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: isMorning ? yellowSoft : const Color(0xFFE8F0FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isMorning ? Icons.wb_sunny : Icons.nightlight_round, 
                  color: isMorning ? yellowText : Colors.blueAccent, 
                  size: 22
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              _buildTypeBadge(isMorning),
            ],
          ),
          const SizedBox(height: 15),
          Text(description, 
            style: const TextStyle(color: Colors.black54, height: 1.4, fontSize: 13)),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: bgSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(tag, style: TextStyle(color: pinkPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(bool isMorning) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMorning ? yellowSoft : const Color(0xFFE8F0FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isMorning ? "PAGI" : "MALAM", 
        style: TextStyle(
          color: isMorning ? yellowText : Colors.blueAccent, 
          fontSize: 9, 
          fontWeight: FontWeight.bold
        )
      ),
    );
  }
}
