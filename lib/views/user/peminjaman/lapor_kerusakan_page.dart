import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/peminjaman.dart';
import '../../../core/services/api_service.dart'; // Asumsi Anda akan menambah method di sini

class LaporKerusakanPage extends StatefulWidget {
  final Peminjaman peminjaman;
  const LaporKerusakanPage({super.key, required this.peminjaman});

  @override
  State<LaporKerusakanPage> createState() => _LaporKerusakanPageState();
}

class _LaporKerusakanPageState extends State<LaporKerusakanPage> {
  final ApiService _apiService = ApiService();
  final _keteranganController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _showImageSourceDialog() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                Navigator.of(context).pop(); // Tutup bottom sheet
                _getImage(ImageSource.camera); // Ambil dari kamera
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Ambil Galeri'),
              onTap: () {
                Navigator.of(context).pop(); // Tutup bottom sheet
                _getImage(ImageSource.gallery); // Ambil dari galeri
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800, // (Opsional) Mengurangi ukuran file gambar
        imageQuality: 85, // (Opsional) Mengurangi kualitas gambar
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Tangani error jika user tidak memberikan izin, dll.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e')),
      );
    }
  }

  void _submitLaporan() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon unggah foto bukti kerusakan.')),
      );
      return;
    }
    if (_keteranganController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi keterangan kerusakan.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await _apiService.submitLaporanKerusakan(
      borrowRequestId: widget.peminjaman.id,
      description: _keteranganController.text,
      imageFile: _imageFile!,
      location: widget.peminjaman.location, // Ambil lokasi dari data peminjaman
    );


    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil dikirim!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(); // Kembali ke halaman detail
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengirim laporan.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lapor Kerusakan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                border: const Border(
                  left: BorderSide(color: Colors.red, width: 4),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Barang mengalami kerusakan? Segera Laporkan!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Silahkan Kirim Bukti Foto Kerusakan Barang',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    _imageFile != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                        : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Ketuk untuk memilih gambar',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Keterangan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _keteranganController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Jelaskan detail kerusakan di sini...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitLaporan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Kirim Laporan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
