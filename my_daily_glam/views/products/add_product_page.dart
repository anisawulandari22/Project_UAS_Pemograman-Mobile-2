import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../models/product_model.dart';

class AddProductPage extends StatefulWidget {
  final Product? product;
  const AddProductPage({super.key, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final Color pinkPrimary = const Color(0xFFE36DAE);
  final Color bgSoft = const Color(0xFFFFF5F7);
  final Color textHint = Colors.grey.shade400;

  late TextEditingController _namaController;
  late TextEditingController _merekController;
  late TextEditingController _hargaController;
  late TextEditingController _tglController;
  late TextEditingController _deskripsiController;

  String selectedCategory = "Pembersih";
  Uint8List? _webImage;
  bool _isLoading = false;

  final List<String> categories = [
    "Pembersih", "Toner", "Serum", "Pelembab", "Tabir Surya", "Masker", "Lainnya"
  ];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.product?.name ?? "");
    _merekController = TextEditingController(text: widget.product?.brand ?? "");
    _hargaController = TextEditingController(text: widget.product?.price.toString() ?? "");
    _tglController = TextEditingController(text: widget.product?.usageTime ?? "");
    _deskripsiController = TextEditingController(text: widget.product?.description ?? "");
    if (widget.product != null) {
      selectedCategory = widget.product!.category;
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: pinkPrimary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _tglController.text = "${picked.month}/${picked.day}/${picked.year}";
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 10,
      maxWidth: 400,
      maxHeight: 400,
    );

    if (image != null) {
      var bytes = await image.readAsBytes();
      setState(() {
        _webImage = bytes;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_namaController.text.isEmpty || _merekController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama dan Merek wajib diisi!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String imageBase64 = widget.product?.imageUrl ?? "";
      if (_webImage != null) {
        imageBase64 = base64Encode(_webImage!);
      }

      final Map<String, dynamic> productData = {
        "name": _namaController.text,
        "brand": _merekController.text,
        "category": selectedCategory,
        "image_url": imageBase64.isNotEmpty ? imageBase64 : "https://via.placeholder.com/150",
        "usage_time": _tglController.text,
        "price": int.tryParse(_hargaController.text) ?? 0,
        "description": _deskripsiController.text,
      };

      bool success;
      if (widget.product == null) {
        success = await ApiService().addProduct(productData);
      } else {
        success = await ApiService().updateProduct(widget.product!.id, productData);
      }

      if (success) {
        if (!mounted) return;
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(widget.product == null ? "Produk berhasil disimpan!" : "Produk berhasil diperbarui!")
          ),
        );
      } else {
        throw "Gagal merespon server. Periksa URL API Anda.";
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text("Error: $e")),
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
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Gambar Produk"),
                      _buildImageUploader(),
                      const SizedBox(height: 20),
                      _buildLabel("Nama Produk"),
                      _buildTextField(_namaController, "misal: Glow Serum"),
                      _buildLabel("Merek"),
                      _buildTextField(_merekController, "misal: skin1004"),
                      _buildLabel("Kategori"),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categories.map((cat) => _buildCategoryChip(cat)).toList(),
                      ),
                      const SizedBox(height: 20),
                      _buildLabel("Harga"),
                      _buildTextField(_hargaController, "misal: 180000", isNumber: true),
                      _buildLabel("Tanggal Kedaluwarsa"),
                      _buildTextField(_tglController, "Pilih tanggal...", isDate: true),
                      _buildLabel("Deskripsi"),
                      _buildTextField(_deskripsiController, "misal: Centella Asiatica", maxLines: 3),
                      const SizedBox(height: 30),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saveProduct,
                          icon: const Icon(Icons.auto_awesome, size: 18),
                          label: Text(widget.product == null ? "Simpan Produk" : "Perbarui Produk", 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pinkPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: pinkPrimary,
              elevation: 2,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.product == null ? "Tambah Produk" : "Edit Produk",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: pinkPrimary)),
                Text(widget.product == null 
                  ? "Lengkapi detail produkmu" 
                  : "Ubah detail produkmu",
                  style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploader() {
    Widget? imagePreview;
    if (_webImage != null) {
      imagePreview = Image.memory(_webImage!, fit: BoxFit.cover);
    } else if (widget.product != null && widget.product!.imageUrl.isNotEmpty) {
      imagePreview = widget.product!.imageUrl.startsWith('http')
          ? Image.network(widget.product!.imageUrl, fit: BoxFit.cover)
          : Image.memory(base64Decode(widget.product!.imageUrl), fit: BoxFit.cover);
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.pink.shade50, width: 2),
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: imagePreview != null 
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    imagePreview,
                    Container(
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.all(10),
                      child: CircleAvatar(
                        backgroundColor: pinkPrimary,
                        radius: 18,
                        child: const Icon(Icons.edit, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.file_upload_outlined, size: 35, color: pinkPrimary),
                    const SizedBox(height: 8),
                    const Text("Klik untuk unggah gambar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text("PNG, JPG hingga 5MB", style: TextStyle(color: textHint, fontSize: 11)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
        style: const TextStyle(color: Color(0xFF8A5CBF), fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, 
      {bool isNumber = false, bool isDate = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        readOnly: isDate,
        onTap: isDate ? _selectDate : null,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: textHint, fontStyle: FontStyle.italic, fontSize: 13),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: isDate ? Icon(Icons.calendar_today_outlined, size: 16, color: pinkPrimary) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: pinkPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    bool isSelected = selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? pinkPrimary.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(color: isSelected ? pinkPrimary : Colors.grey.shade200, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
          style: TextStyle(
            color: isSelected ? pinkPrimary : Colors.grey.shade500,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
