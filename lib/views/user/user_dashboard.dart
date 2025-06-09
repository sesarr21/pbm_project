import 'package:classifly/views/profil.dart';
import 'package:classifly/views/user/userhome_page.dart';
import 'package:flutter/material.dart';
import '../../core/widgets/bottomnav_user.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const UserHomePage(),
    Center(child: Text('Peminjaman Page')),
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
      bottomNavigationBar: BottomNavUser(
        currentIndex: currentIndex,
        onTap: onTabTapped,
      ),
    );
  }
}
