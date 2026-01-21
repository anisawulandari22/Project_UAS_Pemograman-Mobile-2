import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AddJournalPage extends StatefulWidget {
  const AddJournalPage({super.key});

  @override
  State<AddJournalPage> createState() => _AddJournalPageState();
}

class _AddJournalPageState extends State<AddJournalPage> {
  // --- TEMA WARNA ---
  final Color pinkPrimary = const Color(0xFFFF69B4);
  final Color pinkDark = const Color(0xFFD02090);
  final Color bgSoft = const Color(0xFFFFF5F7);
  final Color textHint = Colors.grey.shade400;
  final Color purpleLabel = const Color(0xFF8A5CBF);

  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _produkController = TextEditingController();
  final TextEditingController _kondisiController = TextEditingController();

  String selectedRoutine = "Pagi";
  bool _isLoading = false;

  final List<String> routines = ["Pagi", "Malam", "Spesial"];

  Future<void> _saveJournal() async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Anda harus login terlebih dahulu!")),
      );
      return;
    }

    if (_judulController.text.isEmpty || _produkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul dan Produk wajib diisi!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String formattedDate = DateFormat('dd MMM, yyyy • HH:mm').format(DateTime.now());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('journals')
          .add({
        "title": _judulController.text.trim(),
        "type": selectedRoutine,
        "products": _produkController.text.trim(),
        "condition": _kondisiController.text.trim(),
        "imageUrl": "",
        "timestamp": FieldValue.serverTimestamp(),
        "dateDisplay": "$formattedDate WIB",
      });

      if (!mounted) return;
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Jurnal berhasil disimpan! ✨"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSoft,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: pinkPrimary))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Judul Catatan"),
                        _buildTextField(_judulController, "misal: Rutinitas Pagi Glowing"),
                        
                        _buildLabel("Tipe Rutinitas"),
                        Wrap(
                          spacing: 12,
                          children: routines.map((r) => _buildRoutineChip(r)).toList(),
                        ),
                        const SizedBox(height: 25),

                        _buildLabel("Produk yang Digunakan"),
                        _buildTextField(_produkController, "misal: Cleanser, Toner, Serum..."),
                        
                        _buildLabel("Bagaimana kondisi kulitmu?"),
                        _buildTextField(_kondisiController, "Gambarkan perasaan kulitmu hari ini...", maxLines: 5),
                        
                        const SizedBox(height: 40),
                        
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _saveJournal,
                            icon: const Icon(Icons.auto_awesome, size: 18, color: Colors.yellow),
                            label: const Text("Simpan", 
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: pinkPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 40, left: 40, right: 40),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: pinkPrimary,
              side: BorderSide(color: bgSoft),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Catatan Jurnal Baru",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: pinkDark)),
              const Text("Dokumentasikan perjalanan kulit sehatmu hari ini",
                style: TextStyle(color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
        style: TextStyle(color: purpleLabel, fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: textHint, fontStyle: FontStyle.italic),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: pinkPrimary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildRoutineChip(String label) {
    bool isSelected = selectedRoutine == label;
    return GestureDetector(
      onTap: () => setState(() => selectedRoutine = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? pinkPrimary.withValues(alpha: 0.01) : Colors.white,
          border: Border.all(color: isSelected ? pinkPrimary : Colors.grey.shade200, width: 1.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(label,
          style: TextStyle(
            color: isSelected ? pinkPrimary : Colors.grey.shade500,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _judulController.dispose();
    _produkController.dispose();
    _kondisiController.dispose();
    super.dispose();
  }
}
