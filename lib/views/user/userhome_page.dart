import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_service.dart';
import 'barang/detailbarang_page.dart'; 
import 'peminjaman/daftarpinjam_page.dart';
import 'notifikasi/notifikasi_page.dart'; 


class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  // 1. Buat instance dari ApiService
  final ApiService _apiService = ApiService();

  // Variabel token tidak lagi diperlukan sebagai state di halaman ini
  // String token = '';
  int userId = 0;
  String userName = '';
  List<dynamic> daftarBarang = [];
  bool isLoading = false;
  String searchQuery = '';

  List<Map<String, dynamic>> daftarBarangPinjam = [];

  @override
  void initState() {
    super.initState();
    // 2. Sederhanakan fungsi yang dipanggil di initState
    _loadUserInfoAndFetchBarang();
  }

  // Nama fungsi diubah agar lebih deskriptif
  Future<void> _loadUserInfoAndFetchBarang() async {
    final prefs = await SharedPreferences.getInstance();
    // Mengecek apakah token ada untuk menentukan apakah pengguna sudah login
    final tokenExists = prefs.getString('token') != null;
    
    // Ambil data user lain jika diperlukan
    userId = prefs.getInt('Id') ?? 0;
    userName = prefs.getString('username') ?? '';

    // Hanya panggil API jika pengguna sudah login (memiliki token)
    if (tokenExists) {
      await _fetchBarang();
    }
  }

  Future<void> _fetchBarang() async {
    setState(() {
      isLoading = true;
    });

    // 3. Panggil metode fetchBarang dari instance _apiService
    //    Tidak perlu lagi mengirim parameter token.
    final data = await _apiService.fetchBarang();

    if (mounted) {
      setState(() {
        daftarBarang = data ?? [];
        isLoading = false;
      });
    }
  }

  // Fungsi _buildBarangCard tetap sama, namun pastikan DetailBarangPage
  // yang dituju adalah untuk USER, bukan ADMIN.
  Widget _buildBarangCard(dynamic barang) {
    return GestureDetector(
      onTap: () async {
        final barangTerpilih = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => DetailBarangPage(
                  barang: barang,
                  daftarBarangPinjam: daftarBarangPinjam,
                ),
          ),
        );
        if (barangTerpilih != null) {
          final exists = daftarBarangPinjam.any(
            (b) => b['id'] == barangTerpilih['id'],
          );
          if (!exists) {
            setState(() {
              daftarBarangPinjam.add(barangTerpilih);
            });
          }
        }
      },
      child: Card(
        // ... (UI Card tidak berubah)
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(barang['imageUrl'] ?? ''),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      barang['name'] ?? '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Quantity: ${barang['quantity'] ?? '-'}'),
                    const SizedBox(height: 4),
                    Text('Category: ${barang['categoryName'] ?? '-'}'),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  List<dynamic> get filteredBarang {
    // ... (Fungsi filter tidak berubah)
    if (searchQuery.isEmpty) return daftarBarang;
    return daftarBarang
        .where(
          (item) =>
              item['name'].toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Seluruh kode UI di dalam method build tidak ada perubahan.
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Navbar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/images/logo.png', height: 32),
                      const SizedBox(width: 12),
                      const Text(
                        'Classifly',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F80ED),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Tombol ini lebih cocok digambarkan sebagai keranjang/cart
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        tooltip: 'Daftar Pinjam',
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => DaftarPinjamPage(
                                    daftarBarangPinjam: daftarBarangPinjam,
                                  ),
                            ),
                          );

                          if (result != null &&
                              result is List<Map<String, dynamic>>) {
                            setState(() {
                              daftarBarangPinjam =
                                  List<Map<String, dynamic>>.from(result);
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_none),
                        tooltip: 'Notifikasi',
                        onPressed: () {
                          // Navigasi ke halaman notifikasi
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotifikasiPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Welcome texts
              Text( // Tampilkan nama user jika ada
                'Welcome $userName',
                style: const TextStyle(fontSize: 18, color: Color(0xFF2F80ED)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ready to serve your needs',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Search field
              TextField(
                decoration: InputDecoration(
                  hintText: 'Cari barang...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Daftar Barang
              const Text(
                'Daftar Barang',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (filteredBarang.isEmpty)
                const Text(
                  'Barang tidak ditemukan.',
                  style: TextStyle(color: Colors.grey),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredBarang.length,
                  itemBuilder: (context, index) {
                    return _buildBarangCard(filteredBarang[index]);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}


// Contoh Halaman Detail untuk User (Berbeda dari Admin)
