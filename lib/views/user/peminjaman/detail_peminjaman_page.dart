import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/peminjaman.dart';
import 'lapor_kerusakan_page.dart';

class DetailPeminjamanPage extends StatelessWidget {
  final Peminjaman peminjaman;

  const DetailPeminjamanPage({super.key, required this.peminjaman});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Peminjaman'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peminjaman: #${peminjaman.id}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 32),
                
                // --- DATA DINAMIS DIMULAI DI SINI ---
                _buildDetailRow(Icons.person_outline, 'Nama Peminjam', peminjaman.userName),
                _buildDetailRow(Icons.location_on_outlined, 'Lokasi', peminjaman.location),
                _buildDetailRow(Icons.calendar_today_outlined, 'Tanggal Peminjaman', DateFormat('dd MMMM yyyy', 'id_ID').format(peminjaman.borrowDate)),
                const SizedBox(height: 16),
                
                // Daftar item sekarang dinamis
                _buildDaftarItem(peminjaman.borrowItems), 
                
                const Divider(height: 32),
                _buildStatus(peminjaman),
                const SizedBox(height: 16),
                
                // Pesan admin dinamis, dengan penanganan jika null
                _buildDetailRow(Icons.message_outlined, 'Pesan Admin', peminjaman.adminMessage ?? 'Tidak ada pesan'),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LaporKerusakanPage(peminjaman: peminjaman),
              ),
            );
          },
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
          label: const Text('Lapor Kerusakan', style: TextStyle(color: Colors.white, fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildDetailRow tidak berubah, karena sudah dirancang untuk data dinamis
  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET INI SEKARANG DINAMIS ---
  Widget _buildDaftarItem(List<PeminjamanBarang> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list_alt_outlined, color: Colors.grey[600], size: 20),
            const SizedBox(width: 16),
            Text('Daftar Item', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 36.0),
          // Gunakan Column untuk menampilkan setiap item dari list
          child: Column(
            children: items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.itemName),
                    Text('${item.quantity} pcs'),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Widget _buildStatus tidak berubah
  Widget _buildStatus(Peminjaman peminjaman) {
    return Row(
      children: [
        Icon(peminjaman.statusIcon, color: peminjaman.statusColor, size: 28),
        const SizedBox(width: 12),
        Text(
          peminjaman.statusText,
          style: TextStyle(
            color: peminjaman.statusColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}