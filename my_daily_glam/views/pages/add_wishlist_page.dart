import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddWishlistPage extends StatefulWidget {
  const AddWishlistPage({super.key});

  @override
  State<AddWishlistPage> createState() => _AddWishlistPageState();
}

class _AddWishlistPageState extends State<AddWishlistPage> {
  final Color pinkPrimary = const Color(0xFFFF69B4);
  final Color pinkDark = const Color(0xFFD02090);
  final Color yellowSoft = const Color(0xFFFFF9E6);
  final Color yellowText = const Color(0xFFD4A017);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  Uint8List? _webImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, 
      maxWidth: 800,
      maxHeight: 800,
    );

    if (image != null) {
      var bytes = await image.readAsBytes();
      setState(() => _webImage = bytes);
    }
  }

  Future<void> _saveToMockApi() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nama dan Harga wajib diisi!")));
      return;
    }
    if (_webImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Silakan pilih foto produk!")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      String imageBase64 = base64Encode(_webImage!);
      final response = await http.post(
        Uri.parse("https://6944c4267dd335f4c3612634.mockapi.io/wishlist"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": _nameController.text,
          "price": _priceController.text,
          "image": imageBase64,
          "createdAt": DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        Navigator.pop(context, true); 
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("Berhasil!")));
      } else {
        throw "Gagal menyimpan.";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), 
      child: Container(
        width: MediaQuery.of(context).size.width,
        constraints: const BoxConstraints(maxWidth: 450), 
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tambah Produk Impian",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: pinkDark),
              ),
              const SizedBox(height: 20),
              _buildLabel("Nama Produk"),
              _buildTextField(_nameController, "Contoh: Sunscreen Azarine"),
              const SizedBox(height: 15),
              _buildLabel("Estimasi Harga"),
              _buildTextField(_priceController, "Contoh: 150000", isNumber: true),
              const SizedBox(height: 15),
              _buildLabel("Foto Produk"),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: yellowSoft,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: yellowText.withOpacity(0.1), width: 2),
                  ),
                  child: _webImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.memory(_webImage!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_rounded, color: yellowText, size: 30),
                            Text("Pilih Foto", style: TextStyle(color: yellowText, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveToMockApi,
                    style: ElevatedButton.styleFrom(backgroundColor: pinkPrimary, foregroundColor: Colors.white),
                    child: _isLoading 
                        ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Simpan"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 5),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }
}
