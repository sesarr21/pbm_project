import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../models/notifikasi.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Notifikasi>> _notifikasiFuture;
  List<Notifikasi> _notifikasiList = [];

  @override
  void initState() {
    super.initState();
    _loadNotifikasi();
  }

  void _loadNotifikasi() {
    setState(() {
      _notifikasiFuture = _apiService.getNotifikasi();
    });
  }

  void _handleHapusNotifikasi(int id) async {
    final bool success = await _apiService.hapusNotifikasi(id);
    if (success && mounted) {
      // Jika berhasil, hapus item dari list lokal dan refresh UI
      setState(() {
        _notifikasiList.removeWhere((notif) => notif.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifikasi dihapus.')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus notifikasi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Notifikasi>>(
        future: _notifikasiFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada notifikasi baru.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }
          
          _notifikasiList = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _loadNotifikasi(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifikasiList.length,
              itemBuilder: (context, index) {
                final notifikasi = _notifikasiList[index];
                return _buildNotifikasiCard(notifikasi);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotifikasiCard(Notifikasi notifikasi) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFFE3F2FD), // Warna biru muda
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        title: Text(
          notifikasi.title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            notifikasi.message,
            style: const TextStyle(color: Color(0xFF1565C0)),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1565C0)),
          onPressed: () => _handleHapusNotifikasi(notifikasi.id),
        ),
      ),
    );
  }
}