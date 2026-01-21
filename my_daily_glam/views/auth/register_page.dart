import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:flutter/gestures.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  
  final AuthService _auth = AuthService();
  bool _isLoading = false;

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      var user = await _auth.register(
        _emailController.text.trim(), 
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );
      
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registrasi Berhasil! Silakan Login."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registrasi Gagal. Email mungkin sudah terdaftar."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFE4E1), Color(0xFFFFC0CB)],
              ),
            ),
          ),
          Positioned(
            top: -40,
            right: -40,
            child: Icon(
              Icons.local_florist, 
              size: 200, 
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -30,
            child: Icon(
              Icons.filter_vintage, 
              size: 120, 
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF69B4), Color(0xFFDA70D6)],
                            ),
                          ),
                          child: const Icon(Icons.person_add_alt_1_rounded, size: 50, color: Colors.white),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Buat Akun Glam",
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFD02090)),
                        ),
                        const Text(
                          "Mulai perjalanan glam anda hari ini ✨",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 35),

                        _buildInputLabel("Nama Lengkap"),
                        TextFormField(
                          controller: _nameController,
                          decoration: _buildInputDecoration("Masukkan nama anda", Icons.person_outline),
                          validator: (val) => val!.isEmpty ? "Nama tidak boleh kosong" : null,
                        ),
                        const SizedBox(height: 20),

                        _buildInputLabel("Email"),
                        TextFormField(
                          controller: _emailController,
                          decoration: _buildInputDecoration("your@email.com", Icons.email_outlined),
                          validator: (val) => val!.contains("@") ? null : "Email tidak valid",
                        ),
                        const SizedBox(height: 20),

                        _buildInputLabel("Password"),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword, 
                          decoration: _buildInputDecoration(
                            "Min. 6 karakter", 
                            Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.pinkAccent.withValues(alpha: 0.7),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (val) => val!.length < 6 ? "Password minimal 6 karakter" : null,
                        ),
                        const SizedBox(height: 30),

                        _isLoading 
                        ? const CircularProgressIndicator(color: Color(0xFFFF1493))
                        : Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF1493), Color(0xFFFF69B4)],
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const Text(
                                "Daftar",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black54, fontSize: 14),
                            children: [
                              const TextSpan(text: "Sudah punya akun? "),
                              TextSpan(
                                text: "Login di sini",
                                style: const TextStyle(
                                  color: Color(0xFFFF1493), 
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.pinkAccent),
      suffixIcon: suffix, 
      filled: true,
      fillColor: Colors.pink.withValues(alpha: 0.05),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.pink.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.pinkAccent, width: 1),
      ),
    );
  }
}
