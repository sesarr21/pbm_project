import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../models/peminjaman.dart';
import 'admin_detail_peminjaman_page.dart'; 

class AdminPeminjamanListPage extends StatefulWidget {
  const AdminPeminjamanListPage({super.key});

  @override
  State<AdminPeminjamanListPage> createState() => _AdminPeminjamanListPageState();
}

class _AdminPeminjamanListPageState extends State<AdminPeminjamanListPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Peminjaman>> _peminjamanFuture;

  @override
  void initState() {
    super.initState();
    _peminjamanFuture = _apiService.getSemuaPeminjaman();
  }

  void _refreshData() {
    setState(() {
      _peminjamanFuture = _apiService.getSemuaPeminjaman();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Peminjaman', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),)),
      body: FutureBuilder<List<Peminjaman>>(
        future: _peminjamanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada permintaan peminjaman.'));
          }

          final daftarPeminjaman = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _refreshData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: daftarPeminjaman.length,
              itemBuilder: (context, index) {
                final peminjaman = daftarPeminjaman[index];
                return _buildPeminjamanCard(context, peminjaman);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeminjamanCard(BuildContext context, Peminjaman peminjaman) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: peminjaman.statusColor.withOpacity(0.1),
          child: Icon(peminjaman.statusIcon, color: peminjaman.statusColor),
        ),
        title: Text('Peminjaman: #${peminjaman.id}'),
        subtitle: Text('Peminjam: ${peminjaman.userName}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          // Navigasi ke halaman detail dan tunggu kemungkinan adanya update
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => AdminDetailPeminjamanPage(peminjaman: peminjaman),
            ),
          );
          // Jika halaman detail mengembalikan `true`, berarti ada update, refresh list
          if (result == true) {
            _refreshData();
          }
        },
      ),
    );
  }
}