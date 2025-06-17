import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  Future<void> _launchUri(Uri uri) async {
    if (!await launchUrl(uri)) {
      throw Exception('Tidak dapat membuka $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hubungi Kami', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.phone, color: Color(0xFF2F80ED)),
            title: const Text('Telepon'),
            subtitle: const Text('+62 812 3456 7890'),
            onTap: () => _launchUri(Uri.parse('tel:+6281234567890')),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.email, color: Color(0xFF2F80ED)),
            title: const Text('Email'),
            subtitle: const Text('support@classifly.com'),
            onTap: () => _launchUri(Uri.parse('mailto:support@classifly.com?subject=Bantuan Aplikasi Classifly')),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.public, color: Color(0xFF2F80ED)),
            title: const Text('Website'),
            subtitle: const Text('www.classifly.com'),
            onTap: () => _launchUri(Uri.parse('https://www.classifly.com')),
          ),
        ],
      ),
    );
  }
}