import 'package:flutter/material.dart';

class FaqItem {
  final String question;
  final String answer;

  const FaqItem({required this.question, required this.answer});
}

class FaqsPage extends StatelessWidget {
  const FaqsPage({super.key});

  final List<FaqItem> _faqs = const [
    FaqItem(
      question: 'Bagaimana cara meminjam barang?',
      answer: 'Untuk meminjam barang, buka halaman "Peminjaman", pilih barang yang tersedia, lalu ajukan peminjaman dengan mengisi detail yang diperlukan.',
    ),
    FaqItem(
      question: 'Apa yang harus dilakukan jika barang rusak?',
      answer: 'Jika barang yang Anda pinjam mengalami kerusakan, segera lapor melalui menu "Lapor Kerusakan" pada halaman detail peminjaman Anda.',
    ),
    FaqItem(
      question: 'Bagaimana cara mengubah password saya?',
      answer: 'Anda dapat mengubah password melalui menu "Profil", lalu pilih opsi "Ubah Password". Anda akan diminta memasukkan password lama dan baru.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pertanyaan Umum (FAQs)', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
      ),
      body: ListView.builder(
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final item = _faqs[index];
          return ExpansionTile(
            title: Text(item.question, style: const TextStyle(fontWeight: FontWeight.w500)),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(item.answer, style: TextStyle(color: Colors.grey[700])),
              ),
            ],
          );
        },
      ),
    );
  }
}