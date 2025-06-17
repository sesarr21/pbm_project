import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../models/kategori.dart';

class AdminKategoriPage extends StatefulWidget {
  const AdminKategoriPage({super.key});

  @override
  State<AdminKategoriPage> createState() => _AdminKategoriPageState();
}

class _AdminKategoriPageState extends State<AdminKategoriPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Kategori>> _kategoriFuture;

  @override
  void initState() {
    super.initState();
    _loadKategori();
  }

  void _loadKategori() {
    setState(() {
      _kategoriFuture = _apiService.fetchKategori();
    });
  }

  // Dialog untuk Tambah & Edit Kategori
  void _showKategoriDialog({Kategori? kategori}) {
    final isEditing = kategori != null;
    final controller = TextEditingController(text: isEditing ? kategori.name : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Kategori' : 'Tambah Kategori'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nama Kategori'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isEmpty) return;
                
                final navigator = Navigator.of(context);
                bool success;

                if (isEditing) {
                  success = await _apiService.editKategori(kategori.id, controller.text);
                } else {
                  success = await _apiService.tambahKategori(controller.text);
                }

                if (success) {
                  navigator.pop();
                  _loadKategori(); // Refresh list
                } else {
                  // Tampilkan pesan error jika perlu
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Dialog untuk Konfirmasi Hapus
  void _showHapusDialog(Kategori kategori) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus kategori "${kategori.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final success = await _apiService.hapusKategori(kategori.id);
                if (success) {
                  navigator.pop();
                  _loadKategori(); // Refresh list
                }
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Kategori', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
      ),
      body: FutureBuilder<List<Kategori>>(
        future: _kategoriFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data kategori.'));
          }

          final listKategori = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _loadKategori(),
            child: ListView.builder(
              itemCount: listKategori.length,
              itemBuilder: (context, index) {
                final kategori = listKategori[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    title: Text(kategori.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.amber),
                          onPressed: () => _showKategoriDialog(kategori: kategori),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showHapusDialog(kategori),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showKategoriDialog(),
        tooltip: 'Tambah Kategori',
        backgroundColor: const Color(0xFF2F80ED),
        child: const Icon(Icons.add, color: Colors.white),
        
      ),
    );
  }
}