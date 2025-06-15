import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../models/laporan_kerusakan.dart';
import 'admin_detail_laporan_page.dart'; 

class AdminLaporanListPage extends StatefulWidget {
  const AdminLaporanListPage({super.key});

  @override
  State<AdminLaporanListPage> createState() => _AdminLaporanListPageState();
}

class _AdminLaporanListPageState extends State<AdminLaporanListPage> {
  final ApiService _apiService = ApiService();
  late Future<List<LaporanKerusakan>> _laporanFuture;

  @override
  void initState() {
    super.initState();
    _laporanFuture = _apiService.getSemuaLaporanKerusakan();
  }

  void _refreshData() {
    setState(() {
      _laporanFuture = _apiService.getSemuaLaporanKerusakan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Kerusakan')),
      body: FutureBuilder<List<LaporanKerusakan>>(
        future: _laporanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada laporan kerusakan.'));
          }

          final daftarLaporan = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _refreshData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: daftarLaporan.length,
              itemBuilder: (context, index) {
                final laporan = daftarLaporan[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.receipt_long_outlined)),
                    title: Text('Laporan: #${laporan.id}'),
                    subtitle: Text('Pelapor: ${laporan.userName}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminDetailLaporanPage(laporan: laporan),
                        ),
                      );
                      if (result == true) {
                        _refreshData();
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}