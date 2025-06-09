import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/login_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String fullName = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('fullName') ?? 'Nama tidak tersedia';
      email = prefs.getString('email') ?? 'Email tidak tersedia';
    });
  }

  Widget buildListItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF2F80ED)),
      title: Text(title, style: TextStyle(fontSize: 16)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      dense: true,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profil',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage('assets/images/profile.jpg'),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(email, style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 32),
              Text(
                'Profil & Privasi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    buildListItem(Icons.person, 'Profil'),
                    Divider(height: 1),
                    buildListItem(Icons.location_on, 'Lokasi'),
                    Divider(height: 1),
                    buildListItem(Icons.lock, 'Ubah Password'),
                  ],
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Pengaturan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    buildListItem(Icons.settings, 'Pengaturan'),
                    Divider(height: 1),
                    buildListItem(Icons.info, 'Informasi'),
                    Divider(height: 1),
                    buildListItem(Icons.phone, 'Hubungi Kami'),
                    Divider(height: 1),
                    buildListItem(Icons.help_outline, 'FAQs'),
                    Divider(height: 1),
                    buildListItem(
                      Icons.logout,
                      'Keluar',
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        if (!mounted) return;
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => LoginPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
