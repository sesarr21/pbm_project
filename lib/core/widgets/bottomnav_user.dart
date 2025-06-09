import 'package:flutter/material.dart';

class BottomNavUser extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavUser({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Color(0xFF2F80ED),
      unselectedItemColor: Color(0xFF333333),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: ImageIcon(AssetImage('assets/images/beranda.png'), size: 24),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(AssetImage('assets/images/peminjaman.png'), size: 24),
          label: 'Peminjaman',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(AssetImage('assets/images/profil.png'), size: 24),
          label: 'Profil',
        ),
      ],
    );
  }
}
