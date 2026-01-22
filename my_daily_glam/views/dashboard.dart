import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_daily_glam/views/pages/mood_tracker_page.dart';
import 'products/product_list_page.dart'; 
import 'exit_helper.dart';
import 'pages/journal_page.dart';
import 'pages/wishlist_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  String selectedMenu = "Beranda"; 
  List<bool> skincareValues = [false, false, false, false];
  int selectedMoodIndex = 0;

  List<String> skincareNames = [
    "Gentle Cleanser",
    "Hydrating Toner",
    "Niacinamide Serum",
    "Moisturizer"
  ];

  Widget _getMoodIcon(int type, {double size = 30, Color color = Colors.white}) {
    IconData icon;
    switch (type) {
      case 1: icon = Icons.sentiment_satisfied_alt; break;
      case 2: icon = Icons.sentiment_neutral; break;
      case 3: icon = Icons.sentiment_dissatisfied; break;
      case 4: icon = Icons.sentiment_very_satisfied; break;
      default: icon = Icons.mood;
    }
    return Icon(icon, color: color, size: size);
  }

  final Color pinkPrimary = const Color(0xFFFF69B4);
  final Color pinkDark = const Color(0xFFD02090);
  final Color bgSoft = const Color(0xFFFFF5F7);
  final Color yellowSoft = const Color(0xFFFFF9E6);
  final Color yellowText = const Color(0xFFD4A017);
  
  final LinearGradient pinkGradient = const LinearGradient(
    colors: [Color(0xFFFF69B4), Color(0xFFDA70D6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final List<Map<String, dynamic>> moodData = [
    {"id": 1, "label": "Senang", "color": const Color(0xFF99CC33)},
    {"id": 2, "label": "Biasa", "color": const Color(0xFFD4A017)},
    {"id": 3, "label": "Stress", "color": const Color(0xFFB19CD9)},
    {"id": 4, "label": "Hebat", "color": const Color(0xFFFF69B4)},
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String dateId = DateTime.now().toString().split(' ')[0];

    return Scaffold(
      backgroundColor: bgSoft,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: _buildHeader(),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('moods')
            .doc(dateId)
            .snapshots(),
        builder: (context, moodSnapshot) {
          if (moodSnapshot.hasData && moodSnapshot.data!.exists) {
            final data = moodSnapshot.data!.data() as Map<String, dynamic>;
            if (data['moodType'] != null) {
              selectedMoodIndex = moodData.indexWhere((m) => m['id'] == data['moodType']);
            }
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user?.uid)
                .collection('journals')
                .snapshots(),
            builder: (context, journalSnapshot) {
              if (journalSnapshot.hasData && journalSnapshot.data!.docs.isNotEmpty) {
                List<String> tempNames = [];
                for (var doc in journalSnapshot.data!.docs) {
                  tempNames.add(doc['products'] ?? "Produk Tanpa Nama");
                }
                for (int i = 0; i < tempNames.length && i < 4; i++) {
                  skincareNames[i] = tempNames[i];
                }
              }

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('daily_checklists')
                    .doc(dateId)
                    .snapshots(),
                builder: (context, checkSnapshot) {
                  if (checkSnapshot.hasData && checkSnapshot.data!.exists) {
                    List<dynamic> savedValues = checkSnapshot.data!['values'] ?? [false, false, false, false];
                    for (int i = 0; i < 4; i++) {
                      if (i < savedValues.length) skincareValues[i] = savedValues[i];
                    }
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBannerGlam(),
                        const SizedBox(height: 25),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1.4,
                          children: [
                            _buildActionCard("Jurnal", Icons.auto_stories, const Color(0xFFFFF4E6), const LinearGradient(colors: [Color(0xFFFFD194), Color(0xFFFFB347)])),
                            _buildActionCard("Produk", Icons.inventory_2, const Color(0xFFF8E8FF), const LinearGradient(colors: [Color(0xFFE0C3FC), Color(0xFF8E2DE2)])),
                            _buildActionCard("Wishlist", Icons.favorite, const Color(0xFFFFE8EC), const LinearGradient(colors: [Color(0xFFFF9A9E), Color(0xFFF06292)])),
                            _buildActionCard("Mood", Icons.mood, const Color(0xFFE8F4FF), const LinearGradient(colors: [Color(0xFFA1C4FD), Color(0xFF3081ED)])),
                          ],
                        ),
                        const SizedBox(height: 30),
                        _buildSkincareSection(user?.uid, dateId),
                        const SizedBox(height: 20),
                        _buildMoodSection(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFFFE4E9))),
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: pinkPrimary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.auto_stories), label: "Jurnal"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: "Produk"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Wishlist"),
          BottomNavigationBarItem(icon: Icon(Icons.mood), label: "Mood"),
        ],
        onTap: (index) {
          List<String> menus = ["Beranda", "Jurnal", "Produk", "Wishlist", "Mood"];
          String title = menus[index];
          if (title == "Beranda") return;

          Widget targetPage;
          switch (title) {
            case "Jurnal": targetPage = const JournalPage(); break;
            case "Produk": targetPage = const ProductListPage(); break;
            case "Wishlist": targetPage = const WishlistPage(); break;
            case "Mood": targetPage = const MoodPage(); break;
            default: return;
          }
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => targetPage), (route) => false);
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFFFE4E9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.face_retouching_natural, color: pinkDark, size: 24),
              const SizedBox(width: 8),
              Text("My Daily Glam", style: TextStyle(color: pinkDark, fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
          IconButton(
            onPressed: () => ExitHelper.logout(context),
            icon: Icon(Icons.logout, color: pinkPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerGlam() {
    final user = FirebaseAuth.instance.currentUser;
    final String userName = (user?.displayName != null && user!.displayName!.isNotEmpty) 
      ? user.displayName! 
      : (user?.email?.split('@')[0] ?? "User");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: pinkGradient,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hai, $userName! ✨", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 5),
          const Text("Kulitmu bersinar hari ini!", style: TextStyle(fontSize: 14, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color bgColor, LinearGradient iconGrad) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          Widget targetPage;
          switch (title) {
            case "Jurnal": targetPage = const JournalPage(); break;
            case "Produk": targetPage = const ProductListPage(); break;
            case "Wishlist": targetPage = const WishlistPage(); break;
            case "Mood": targetPage = const MoodPage(); break;
            default: return;
          }
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => targetPage), (route) => false);
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(gradient: iconGrad, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)), 
          ],
        ),
      ),
    );
  }

  Widget _buildSkincareSection(String? uid, String dateId) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Jadwal Skincare", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), 
              Text(dateId, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 15),
          _skincareRow(0, skincareNames[0], "PAGI", uid, dateId),
          _skincareRow(1, skincareNames[1], "PAGI", uid, dateId),
          _skincareRow(2, skincareNames[2], "MALAM", uid, dateId),
          _skincareRow(3, skincareNames[3], "PAGI", uid, dateId),
        ],
      ),
    );
  }

  Widget _skincareRow(int index, String title, String tag, String? uid, String dateId) {
    bool isMorning = tag == "PAGI";
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: const Color(0xFFFFF9FA), borderRadius: BorderRadius.circular(15)),
      child: CheckboxListTile(
        value: skincareValues[index],
        activeColor: pinkPrimary,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
        onChanged: (bool? newValue) async {
          setState(() => skincareValues[index] = newValue!);
          if (uid != null) {
            await FirebaseFirestore.instance.collection('users').doc(uid).collection('daily_checklists').doc(dateId).set({
              'values': skincareValues,
              'lastUpdated': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        },
        secondary: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isMorning ? yellowSoft : const Color(0xFFF8E8FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(tag, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: isMorning ? yellowText : const Color(0xFF8E2DE2))),
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildMoodSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]
      ),
      child: Column(
        children: [
          const Align(alignment: Alignment.centerLeft, child: Text("Pelacak Mood", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(moodData.length, (index) {
              return _moodIcon(index, moodData[index]["label"], moodData[index]["color"], selectedMoodIndex == index);
            }),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                int moodId = moodData[selectedMoodIndex]["id"];
                String moodLabel = moodData[selectedMoodIndex]["label"];
                String dateId = DateTime.now().toString().split(' ')[0];

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('moods')
                    .doc(dateId)
                    .set({
                  'moodType': moodId,
                  'label': moodLabel,
                  'date': dateId,
                  'timestamp': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Mood $moodLabel disimpan! ✨"), backgroundColor: pinkDark)
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: pinkPrimary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Simpan Mood", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moodIcon(int index, String label, Color color, bool active) {
    return InkWell(
      onTap: () => setState(() => selectedMoodIndex = index),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 50, height: 50,
            decoration: BoxDecoration(color: active ? color : Colors.grey.withOpacity(0.1), shape: BoxShape.circle),
            child: Center(child: _getMoodIcon(moodData[index]["id"], color: active ? Colors.white : Colors.grey)),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.w900 : FontWeight.normal, color: active ? pinkDark : Colors.grey)),
        ],
      ),
    );
  }
}
