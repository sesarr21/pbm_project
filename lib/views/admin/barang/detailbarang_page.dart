import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import 'editbarang_page.dart';
import '../../../models/barang.dart';

class DetailBarangPage extends StatelessWidget {
  final Map<String, dynamic> barang;

  const DetailBarangPage({super.key, required this.barang});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Barang')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar full width
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: Image.network(
                  barang['imageUrl'] ?? '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                ),
              ),
            ),

            // Konten detail
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    barang['name'] ?? '-',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${barang['description'] ?? '-'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Kategori',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${barang['categoryName'] ?? '-'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Kuantitas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${barang['quantity'] ?? '-'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Tombol Hapus
          FloatingActionButton(
            heroTag: 'hapus',
            onPressed: () {
              // TODO: Tambahkan aksi hapus di sini
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Konfirmasi Hapus Barang?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          const Icon(
                            Icons.warning,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Apakah anda yakin ingin menghapus barang ini?',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context); // tutup dialog dulu

                            final prefs = await SharedPreferences.getInstance();
                            final token = prefs.getString('token') ?? '';

                            final id = barang['id']; // pastikan ini integer

                            final success = await ApiService.hapusBarang(
                              token: token,
                              id: id,
                            );

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Barang berhasil dihapus'),
                                ),
                              );
                              Navigator.pop(
                                context,
                                true,
                              ); // kembali ke halaman sebelumnya + sinyal refresh
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Gagal menghapus barang'),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Hapus',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );
            },
            backgroundColor: Colors.red,
            child: const Icon(Icons.delete),
          ),
          const SizedBox(width: 16),
          // Tombol Edit
          FloatingActionButton(
            heroTag: 'edit',
            onPressed: () {
              final barangModel = Barang.fromJson(barang);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditBarangPage(barang: barangModel),
                ),
              );
            },
            backgroundColor: Colors.amber,
            child: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }
}
