import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../../../models/kategori.dart';
import '../../../models/barang.dart';
import '../adminhome_page.dart';

class EditBarangPage extends StatefulWidget {
  final Barang barang;

  const EditBarangPage({super.key, required this.barang});

  @override
  State<EditBarangPage> createState() => _EditBarangPageState();
}

class _EditBarangPageState extends State<EditBarangPage> {
  File? _imageFile;
  final picker = ImagePicker();

  late TextEditingController namaController;
  late TextEditingController kuantitasController;
  late TextEditingController deskripsiController;

  List<Kategori> kategoriList = [];
  Kategori? selectedKategori;
  String token = '';

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.barang.name);
    kuantitasController = TextEditingController(
      text: widget.barang.quantity.toString(),
    );
    deskripsiController = TextEditingController(
      text: widget.barang.description,
    );
    loadTokenAndKategori();
  }

  Future<void> loadTokenAndKategori() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token') ?? '';
    setState(() => token = savedToken);

    try {
      final kategori = await ApiService.fetchKategori(token);
      setState(() {
        kategoriList = kategori;
        selectedKategori = kategori.firstWhere(
          (k) => k.id == widget.barang.categoryId,
          orElse: () => kategori.first,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memuat kategori')));
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void simpanBarang() async {
    if (namaController.text.isEmpty ||
        selectedKategori == null ||
        kuantitasController.text.isEmpty ||
        deskripsiController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harap isi semua data')));
      return;
    }

    final kuantitas = int.tryParse(kuantitasController.text) ?? 0;

    final success = await ApiService.editBarang(
      token: token,
      id: widget.barang.id,
      nama: namaController.text,
      kategoriId: selectedKategori!.id,
      kuantitas: kuantitas,
      deskripsi: deskripsiController.text,
      gambar: _imageFile,
      existingImageUrl: widget.barang.imageUrl,
    );

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Barang berhasil disimpan')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminHomePage()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal menyimpan barang')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Edit Barang',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F80ED),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Gambar Barang',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder:
                        (_) => Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Ambil dari Kamera'),
                              onTap: () {
                                Navigator.pop(context);
                                pickImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Ambil dari Galeri'),
                              onTap: () {
                                Navigator.pop(context);
                                pickImage(ImageSource.gallery);
                              },
                            ),
                          ],
                        ),
                  );
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[100],
                  ),
                  child:
                      _imageFile != null
                          ? Image.file(_imageFile!, fit: BoxFit.cover)
                          : widget.barang.imageUrl.isNotEmpty
                          ? Image.network(
                            widget.barang.imageUrl,
                            fit: BoxFit.cover,
                          )
                          : const Center(child: Text('Pilih gambar')),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Nama Barang',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: namaController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama barang',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Kategori',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Kategori>(
                value: selectedKategori,
                hint: const Text('Pilih kategori'),
                items:
                    kategoriList.map((kategori) {
                      return DropdownMenuItem<Kategori>(
                        value: kategori,
                        child: Text(kategori.name),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => selectedKategori = value),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Kuantitas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: kuantitasController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Masukkan jumlah kuantitas',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Deskripsi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: deskripsiController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Masukkan deskripsi barang',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: simpanBarang,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2C94C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Simpan Barang',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
