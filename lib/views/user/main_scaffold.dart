import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:classifly/core/widgets/bottomnav_user.dart'; // Import widget navbar Anda

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  // Fungsi untuk menentukan index navbar yang aktif berdasarkan route saat ini
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/peminjaman-list')) {
      return 1;
    }
    if (location.startsWith('/profile')) {
      return 2;
    }
    return 0;
  }

  // Fungsi untuk navigasi saat item navbar diklik
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        // Navigasi ke peminjaman list tanpa parameter 'extra'
        // akan menampilkan tab default (index 0)
        context.go('/peminjaman-list'); 
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child, // GoRouter akan menempatkan halaman di sini
      // Gunakan widget BottomNavUser kustom Anda
      bottomNavigationBar: BottomNavUser(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }
}