import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
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
  final Color yellowSoft = const Color(0xFFFFF9E6);
  final Color yellowText = const Color(0xFFD4A017);
  
  int _selectedIndex = 4;

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
              Text(
                "Pelacak Mood",
                style: TextStyle(
                  fontSize: 26, 
                  fontWeight: FontWeight.w900, 
                  color: pinkDark
                ),
              ),
              const Text(
                "Pantau suasana hati dan kesejahteraanmu",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 25),
              _buildCalendarCard(),
              const SizedBox(height: 20),
              _buildLegend(),
            ],
          ),
        ),
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

  Widget _buildCalendarCard() {
    String currentMonthName = DateFormat('MMMM yyyy').format(DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02), 
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
              Text(
                currentMonthName, 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              Icon(Icons.calendar_month, color: pinkPrimary),
            ],
          ),
          const SizedBox(height: 20),
          _buildDaysHeader(),
          const SizedBox(height: 10),
          _buildDaysGrid(), 
        ],
      ),
    );
  }

  Widget _buildDaysHeader() {
    List<String> days = ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) => Expanded(
        child: Center(
          child: Text(
            day, 
            style: TextStyle(color: pinkDark, fontWeight: FontWeight.bold, fontSize: 11)
          )
        ),
      )).toList(),
    );
  }

  Widget _buildDaysGrid() {
    final user = FirebaseAuth.instance.currentUser;
    DateTime now = DateTime.now();
    int daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    int firstDayOffset = DateTime(now.year, now.month, 1).weekday % 7;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('moods')
          .snapshots(),
      builder: (context, snapshot) {
        Map<int, Map<String, dynamic>> firestoreMoodData = {};

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            try {
              DateTime date = DateTime.parse(doc.id);
              if (date.month == now.month && date.year == now.year) {
                firestoreMoodData[date.day] = doc.data() as Map<String, dynamic>;
              }
            } catch (e) {
              debugPrint("Error parsing date: $e");
            }
          }
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: daysInMonth + firstDayOffset,
          itemBuilder: (context, index) {
            if (index < firstDayOffset) return const SizedBox.shrink(); 
            
            int day = index - firstDayOffset + 1;
            var data = firestoreMoodData[day];

            return GestureDetector(
              onTap: () => _showMoodDialog(day, data),
              child: Container(
                decoration: BoxDecoration(
                  color: data != null ? _getMoodColor(data['moodType'] ?? 1) : Colors.transparent,
                  shape: BoxShape.circle,
                  border: data == null ? Border.all(color: bgSoft, width: 1) : null,
                ),
                child: Center(
                  child: data != null 
                    ? _getMoodIcon(data['moodType'] ?? 1, size: 18)
                    : Text("$day", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMoodDialog(int day, Map<String, dynamic>? existingData) {
    int tempSelectedMood = existingData?['moodType'] ?? 1;
    TextEditingController descController = TextEditingController(text: existingData?['note'] ?? "");
    final user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Mood Tanggal $day", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                ),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 15,
                  runSpacing: 15,
                  children: [1, 2, 3, 4].map((type) {
                    bool isThisSelected = tempSelectedMood == type;
                    return GestureDetector(
                      onTap: () => setDialogState(() => tempSelectedMood = type),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: _getMoodColor(type).withOpacity(isThisSelected ? 1 : 0.1),
                            radius: 25,
                            child: _getMoodIcon(type, size: 24, color: isThisSelected ? Colors.white : _getMoodColor(type)),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _getMoodName(type), 
                            style: TextStyle(
                              fontSize: 10, 
                              fontWeight: isThisSelected ? FontWeight.bold : FontWeight.normal,
                              color: isThisSelected ? pinkDark : Colors.grey
                            )
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "Ceritakan perasaanmu...",
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                    filled: true,
                    fillColor: bgSoft,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (user == null) return;
                      DateTime now = DateTime.now();
                      String dateId = "${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('moods')
                          .doc(dateId)
                          .set({
                        'moodType': tempSelectedMood,
                        'label': _getMoodName(tempSelectedMood), 
                        'date': dateId, 
                        'note': descController.text,
                        'timestamp': FieldValue.serverTimestamp(),
                      }, SetOptions(merge: true));

                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Mood tanggal $day disimpan!"), backgroundColor: pinkDark)
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pinkPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text("SIMPAN", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _legendItem(1, "Senang"),
            _legendItem(2, "Biasa"),
            _legendItem(3, "Stress"),
            _legendItem(4, "Hebat"),
          ],
        ),
      ],
    );
  }

  Widget _legendItem(int type, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: _getMoodColor(type), shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
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
}
