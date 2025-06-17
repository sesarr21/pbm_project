import 'package:classifly/views/admin/adminhome_page.dart';
import 'package:classifly/views/admin/laporan/admin_laporan_list_page.dart';
import 'package:classifly/views/admin/peminjaman/admin_peminjaman_page.dart';
import 'package:classifly/views/profil.dart';
import 'package:flutter/material.dart';
import '../../core/widgets/bottomnav_admin.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const AdminHomePage(),
    const AdminPeminjamanListPage(),
    const AdminLaporanListPage(),
    const ProfilPage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavAdmin(
        currentIndex: currentIndex,
        onTap: onTabTapped,
      ),
    );
  }
}
