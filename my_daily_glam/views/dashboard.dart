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

  Widget _getMoodIcon(int type, {double size = 40, Color color = Colors.white}) {
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
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
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
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildBannerGlam(),
                                    const SizedBox(height: 35),
                                    Row(
                                      children: [
                                        _buildActionCard("Jurnal", Icons.auto_stories, const Color(0xFFFFF4E6), 
                                            const LinearGradient(colors: [Color(0xFFFFD194), Color(0xFFFFB347)])),
                                        const SizedBox(width: 15),
                                        _buildActionCard("Produk", Icons.inventory_2, const Color(0xFFF8E8FF), 
                                            const LinearGradient(colors: [Color(0xFFE0C3FC), Color(0xFF8E2DE2)])),
                                        const SizedBox(width: 15),
                                        _buildActionCard("Wishlist", Icons.favorite, const Color(0xFFFFE8EC), 
                                            const LinearGradient(colors: [Color(0xFFFF9A9E), Color(0xFFF06292)])),
                                        const SizedBox(width: 15),
                                        _buildActionCard("Mood", Icons.mood, const Color(0xFFE8F4FF), 
                                            const LinearGradient(colors: [Color(0xFFA1C4FD), Color(0xFF3081ED)])),
                                      ],
                                    ),
                                    const SizedBox(height: 40),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(flex: 7, child: _buildSkincareSection(user?.uid, dateId)),
                                        const SizedBox(width: 24),
                                        Expanded(flex: 5, child: _buildMoodSection()),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
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
            if (selectedMenu == title) return;
            
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
            label: const Text("Keluar", style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildBannerGlam() {
    final user = FirebaseAuth.instance.currentUser;
    final String userName = (user?.displayName != null && user!.displayName!.isNotEmpty) 
      ? user.displayName! 
      : (user?.email?.split('@')[0] ?? "User");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: pinkGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: pinkPrimary.withValues(alpha: 0.03), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hai, $userName! ✨", 
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 5),
          const Text("Kulitmu bersinar hari ini. Siap untuk rutinitasmu?", 
            style: TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color bgColor, LinearGradient iconGrad) {
    return Expanded(
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(25),
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
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => targetPage),
              (route) => false,
            );
          },
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(gradient: iconGrad, shape: BoxShape.circle),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkincareSection(String? uid, String dateId) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Jadwal Skincare", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), 
              Text(dateId, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: const Color(0xFFFFF9FA), borderRadius: BorderRadius.circular(15)),
      child: CheckboxListTile(
        value: skincareValues[index],
        activeColor: pinkPrimary,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        onChanged: (bool? newValue) async {
          setState(() {
            skincareValues[index] = newValue!;
          });

          if (uid != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('daily_checklists')
                .doc(dateId)
                .set({
              'values': skincareValues,
              'lastUpdated': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        },
        secondary: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isMorning ? yellowSoft : const Color(0xFFF8E8FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(tag, style: TextStyle(
            fontSize: 10, 
            fontWeight: FontWeight.w900, 
            color: isMorning ? yellowText : const Color(0xFF8E2DE2)
          )),
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildMoodSection() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft, 
            child: Text("Pelacak Mood", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(moodData.length, (index) {
              return _moodIcon(
                index,
                moodData[index]["label"],
                moodData[index]["color"],
                selectedMoodIndex == index,
              );
            }),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                int moodId = moodData[selectedMoodIndex]["id"];
                String moodLabel = moodData[selectedMoodIndex]["label"];
                String dateId = DateTime.now().toString().split(' ')[0];

                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('moods')
                      .doc(dateId)
                      .set({
                    'moodType': moodId,
                    'note': "Mood harian dari Dashboard",
                    'timestamp': FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Mood '$moodLabel' berhasil disimpan! ✨"), 
                      backgroundColor: pinkDark
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Gagal menyimpan ke database")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: pinkPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Simpan Mood", style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moodIcon(int index, String label, Color color, bool active) {
    int moodId = moodData[index]["id"];
    
    return InkWell(
      onTap: () => setState(() => selectedMoodIndex = index),
      borderRadius: BorderRadius.circular(15),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: active ? color : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              boxShadow: active ? [
                BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))
              ] : [],
            ),
            child: Center(
              child: _getMoodIcon(
                moodId, 
                size: 32, 
                color: active ? Colors.white : Colors.grey
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label, 
            style: TextStyle(
              fontSize: 12, 
              fontWeight: active ? FontWeight.w900 : FontWeight.normal,
              color: active ? pinkDark : Colors.grey
            )
          ),
        ],
      ),
    );
  }
}
