import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../dashboard_page.dart';
import '../exit_helper.dart';
import 'journal_page.dart';
import '../products/product_list_page.dart';
import 'wishlist_page.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  final Color pinkPrimary = const Color(0xFFFF69B4);
  final Color pinkDark = const Color(0xFFD02090);
  final Color bgSoft = const Color(0xFFFFF5F7);
  final Color pinkLight = const Color(0xFFFFE4E9);
  final Color yellowSoft = const Color(0xFFFFF9E6);
  final Color yellowText = const Color(0xFFD4A017);
  
  String selectedMenu = "Mood";

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
                        Text(
                          "Pelacak Mood",
                          style: TextStyle(
                            fontSize: 32, 
                            fontWeight: FontWeight.w900, 
                            color: pinkDark
                          ),
                        ),
                        const Text(
                          "Pantau suasana hati dan kesejahteraanmu secara real-time",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCalendarCard(),
                            const SizedBox(width: 40),
                          ],
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

  Widget _buildCalendarCard() {
    return Container(
      width: 450,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Januari 2026", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
              ),
              Icon(Icons.calendar_month, color: pinkPrimary),
            ],
          ),
          const SizedBox(height: 25),
          _buildDaysHeader(),
          const SizedBox(height: 15),
          _buildDaysGrid(), 
        ],
      ),
    );
  }

  Widget _buildDaysHeader() {
    List<String> days = ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) => SizedBox(
        width: 45,
        child: Center(
          child: Text(
            day, 
            style: TextStyle(color: pinkDark, fontWeight: FontWeight.bold, fontSize: 12)
          )
        ),
      )).toList(),
    );
  }

  Widget _buildDaysGrid() {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('moods')
          .snapshots(),
      builder: (context, snapshot) {
        Map<int, List<dynamic>> firestoreMoodData = {};

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            try {
              DateTime date = DateTime.parse(doc.id);
              if (date.month == 1 && date.year == 2026) {
                firestoreMoodData[date.day] = [doc['moodType'], doc['note'] ?? ""];
              }
            } catch (e) {
              debugPrint("Error parsing date: $e");
            }
          }
        }

        return Wrap(
          spacing: 12,
          runSpacing: 15,
          children: List.generate(31 + 4, (index) {
            if (index < 4) return const SizedBox(width: 45, height: 45); 
            int day = index - 3;
            var data = firestoreMoodData[day];

            return GestureDetector(
              onTap: () => _showMoodDialog(day, data),
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: data != null ? _getMoodColor(data[0]) : Colors.transparent,
                  shape: BoxShape.circle,
                  border: data == null ? Border.all(color: bgSoft, width: 2) : null,
                ),
                child: Center(
                  child: data != null 
                    ? _getMoodIcon(data[0])
                    : Text("$day", style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  void _showMoodDialog(int day, List<dynamic>? existingData) {
    int tempSelectedMood = existingData?[0] ?? 1;
    TextEditingController descController = TextEditingController(text: existingData?[1] ?? "");
    final user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Bagaimana perasaanmu tanggal $day?", 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [1, 2, 3, 4].map((type) {
                  bool isThisSelected = tempSelectedMood == type;
                  return GestureDetector(
                    onTap: () => setDialogState(() => tempSelectedMood = type),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: _getMoodColor(type).withValues(alpha: isThisSelected ? 1 : 0.2),
                          radius: 28,
                          child: _getMoodIcon(type, size: 28, color: isThisSelected ? Colors.white : _getMoodColor(type)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getMoodName(type), 
                          style: TextStyle(
                            fontSize: 11, 
                            fontWeight: isThisSelected ? FontWeight.bold : FontWeight.normal,
                            color: isThisSelected ? pinkDark : Colors.grey
                          )
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Ceritakan sedikit perasaanmu...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  filled: true,
                  fillColor: bgSoft.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (user == null) return;

                    String dateId = "2026-01-${day.toString().padLeft(2, '0')}";

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('moods')
                        .doc(dateId)
                        .set({
                      'moodType': tempSelectedMood,
                      'note': descController.text,
                      'timestamp': FieldValue.serverTimestamp(),
                    });

                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pinkPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                  ),
                  child: const Text("SIMPAN", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getMoodName(int type) {
    switch (type) {
      case 1: return "Senang";
      case 2: return "Biasa";
      case 3: return "Stress";
      case 4: return "Hebat";
      default: return "";
    }
  }

  Color _getMoodColor(int type) {
    switch (type) {
      case 1: return const Color(0xFF99CC33);
      case 2: return yellowText;
      case 3: return const Color(0xFFB19CD9);
      case 4: return pinkPrimary;
      default: return Colors.transparent;
    }
  }

  Widget _getMoodIcon(int type, {double size = 22, Color color = Colors.white}) {
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
          _buildNavMenu(Icons.home, "Beranda", const DashboardPage()),
          _buildNavMenu(Icons.auto_stories, "Jurnal", const JournalPage()),
          _buildNavMenu(Icons.inventory_2, "Produk", const ProductListPage()),
          _buildNavMenu(Icons.favorite, "Wishlist", const WishlistPage()),
          _buildNavMenu(Icons.mood, "Mood", const MoodPage()),
        ],
      ),
    );
  }

  Widget _buildNavMenu(IconData icon, String title, Widget target) {
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
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => target),
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
}
