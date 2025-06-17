import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _areNotificationsOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Mode Gelap'),
            subtitle: const Text('Aktifkan tema gelap untuk kenyamanan mata.'),
            secondary: Icon(_isDarkMode? Icons.dark_mode : Icons.light_mode),
            value: _isDarkMode,
            onChanged: (bool value) {
              setState(() {
                _isDarkMode = value;

              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Notifikasi Aplikasi'),
            subtitle: const Text('Terima pembaruan penting dari aplikasi.'),
            secondary: Icon(_areNotificationsOn ? Icons.notifications_active : Icons.notifications_off),
            value: _areNotificationsOn,
            onChanged: (bool value) {
              setState(() {
                _areNotificationsOn = value;
              });
            },
          ),
        ],
      ),
    );
  }
}