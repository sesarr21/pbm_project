import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../admin_dashboard.dart';
import 'editbarang_page.dart';
import '../../../models/barang.dart';

// 1. Diubah menjadi StatefulWidget
class DetailBarangPage extends StatefulWidget {
  final Map<String, dynamic> barang;

  const DetailBarangPage({super.key, required this.barang});

  @override
  State<DetailBarangPage> createState() => _DetailBarangPageState();
}

class _DetailBarangPageState extends State<DetailBarangPage> {
  // 2. Instance ApiService dibuat di sini, di dalam class State
  final ApiService _apiService = ApiService();

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
                // 3. Akses 'barang' menggunakan widget.barang
                child: Image.network(
                  widget.barang['imageUrl'] ?? '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
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
                    widget.barang['name'] ?? '-',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${widget.barang['description'] ?? '-'}',
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
                    '${widget.barang['categoryName'] ?? '-'}',
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
                    '${widget.barang['quantity'] ?? '-'}',
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
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Konfirmasi Hapus Barang?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Icon(
                        Icons.warning,
                        color: Colors.red,
                        size: 48,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Apakah anda yakin ingin menghapus barang ini?',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () async {
                        
                        final navigator = Navigator.of(context);
                        final scaffoldMessenger = ScaffoldMessenger.of(context);


                        final id = widget.barang['id'];
                        final success = await _apiService.hapusBarang(id: id);


                        if (!mounted) return;

                        navigator.pop(); 

                        if (success) {
                          scaffoldMessenger.showSnackBar( 
                            const SnackBar(
                              content: Text('Barang berhasil dihapus'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const AdminDashboard()), 
                              (route) => false,
                          );

                        } else {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Gagal menghapus barang'),
                              backgroundColor: Colors.red,
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
              final barangModel = Barang.fromJson(widget.barang);

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