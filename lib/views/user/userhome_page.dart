import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_service.dart';
import 'barang/detailbarang_page.dart';
import 'peminjaman/daftarpinjam_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  String token = '';
  List<dynamic> daftarBarang = [];
  bool isLoading = false;
  String searchQuery = '';

  List<dynamic> daftarBarangPinjam = [];

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchBarang();
  }

  Future<void> _loadTokenAndFetchBarang() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token') ?? '';

    setState(() {
      token = savedToken;
    });

    if (token.isNotEmpty) {
      await _fetchBarang();
    }
  }

  Future<void> _fetchBarang() async {
    setState(() {
      isLoading = true;
    });

    final data = await ApiService.fetchBarang(token);

    setState(() {
      daftarBarang = data ?? [];
      isLoading = false;
    });
  }

  Widget _buildBarangCard(dynamic barang) {
    return GestureDetector(
      onTap: () async {
        final barangTerpilih = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailBarangPage(barang: barang),
          ),
        );
        if (barangTerpilih != null) {
          setState(() {
            daftarBarangPinjam.add(barangTerpilih);
          });
        }
      },
      child: Card(
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
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: 'Tambahkan',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => DaftarPinjamPage(
                                    daftarBarangPinjam: daftarBarangPinjam,
                                  ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_none),
                        tooltip: 'Notifikasi',
                        onPressed: () {
                          // TODO: Navigasi ke halaman notifikasi
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Welcome texts
              const Text(
                'Welcome User',
                style: TextStyle(fontSize: 18, color: Color(0xFF2F80ED)),
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
