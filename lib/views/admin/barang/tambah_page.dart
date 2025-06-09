import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../adminhome_page.dart';

class AddBarangPage extends StatefulWidget {
  const AddBarangPage({super.key});

  @override
  State<AddBarangPage> createState() => _AddBarangPageState();
}

class _AddBarangPageState extends State<AddBarangPage> {
  File? _imageFile;
  final picker = ImagePicker();

  final TextEditingController namaController = TextEditingController();
  final TextEditingController kuantitasController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  String? selectedKategori;
  String token = '';

  final List<String> kategoriList = [
    'Elektronik',
    'Kebutuhan Kelas',
    'Alat Tulis',
  ];

  final Map<String, int> kategoriMap = {
    'Elektronik': 1,
    'Kebutuhan Kelas': 2,
    'Alat Tulis': 3,
  };

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? '';
    });
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void tambahBarang() async {
    if (namaController.text.isEmpty ||
        selectedKategori == null ||
        kuantitasController.text.isEmpty ||
        deskripsiController.text.isEmpty ||
        _imageFile == null) {
      // Pastikan gambar sudah dipilih
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua data termasuk gambar')),
      );
      return;
    }

    final kategoriId = kategoriMap[selectedKategori!];
    if (kategoriId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kategori tidak valid')));
      return;
    }

    final kuantitas = int.tryParse(kuantitasController.text) ?? 0;

    final success = await ApiService.tambahBarang(
      token: token,
      nama: namaController.text,
      kategoriId: kategoriId,
      kuantitas: kuantitas,
      deskripsi: deskripsiController.text,
      gambar: _imageFile,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barang berhasil ditambahkan')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminHomePage()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal menambahkan barang')));
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
              // Navbar atas
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminHomePage(),
                        ),
                      );
                    },
                  ),
                  const Text(
                    'Input Barang',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F80ED),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Gambar Barang
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
                      _imageFile == null
                          ? const Center(child: Text('Pilih gambar'))
                          : Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 24),

              // Nama Barang
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

              // Kategori (Dropdown)
              const Text(
                'Kategori',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedKategori,
                hint: const Text('Pilih kategori'),
                items:
                    kategoriList.map((String kategori) {
                      return DropdownMenuItem<String>(
                        value: kategori,
                        child: Text(kategori),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedKategori = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Kuantitas
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

              // Deskripsi
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

              // Tombol Tambah Barang
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: tambahBarang,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Tambah Barang',
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
