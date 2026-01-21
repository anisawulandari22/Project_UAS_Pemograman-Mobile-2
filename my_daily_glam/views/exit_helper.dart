import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExitHelper {
  static Future<void> logout(BuildContext context) async {
    try {
      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Konfirmasi Keluar"),
          content: const Text("Apakah kamu yakin ingin keluar dari akun?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Keluar", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ) ?? false;

      if (confirm) {
        await FirebaseAuth.instance.signOut();

        if (!context.mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Berhasil keluar ✨"),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error saat logout: $e");
    }
  }
}
