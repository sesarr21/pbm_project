import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
                    backgroundImage: AssetImage('assets/images/foto_profil.png'),
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
                    buildListItem(Icons.location_on, 'Lokasi', onTap: () => context.push('/profile/location')),
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
                    buildListItem(Icons.settings, 'Pengaturan',
                        onTap: () => context.push('/settings')),
                    const Divider(height: 1),
                    buildListItem(Icons.info, 'Informasi',
                        onTap: () => context.push('/information')),
                    const Divider(height: 1),
                    buildListItem(Icons.phone, 'Hubungi Kami',
                        onTap: () => context.push('/contact-us')),
                    const Divider(height: 1),
                    buildListItem(Icons.help_outline, 'FAQs',
                        onTap: () => context.push('/faqs')),
                    const Divider(height: 1),
                    buildListItem(
                      Icons.logout,
                      'Keluar',
                      onTap: () async {
            
                        final bool? shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Konfirmasi Keluar'),
                            content: const Text('Apakah Anda yakin ingin keluar?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Ya, Keluar'),
                              ),
                            ],
                          ),
                        );

                 
                        if (shouldLogout != true) {
                          return;
                        }

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();

                        if (!context.mounted) return;

                        context.go('/login');
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
