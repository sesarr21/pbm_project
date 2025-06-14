import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_service.dart';
import 'barang/tambah_page.dart';
import 'barang/detailbarang_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String token = '';
  List<dynamic> daftarBarang = [];
  bool isLoading = false;
  final ApiService _apiService = ApiService();

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

    final data = await _apiService.fetchBarang();

    setState(() {
      daftarBarang = data ?? [];
      isLoading = false;
    });
  }

  Widget _buildBarangCard(dynamic barang) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailBarangPage(barang: barang),
          ),
        );

        if (result == true) {
          _fetchBarang();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBarangPage()),
          ).then((_) {
            _fetchBarang(); // Refresh data setelah menambahkan
          });
        },
        backgroundColor: const Color(0xFF2F80ED),
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Welcome Admin',
                style: TextStyle(fontSize: 18, color: Color(0xFF2F80ED)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Start Tracking!',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              TextField(
                decoration: InputDecoration(
                  hintText: 'Cari barang...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  // Optional: implement search logic
                },
              ),
              const SizedBox(height: 24),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.4,
                children: [
                  _buildStatCard(
                    'assets/images/total_barang.png',
                    daftarBarang.length.toString(),
                    'Total Barang',
                  ),
                  _buildStatCard(
                    'assets/images/total_peminjaman.png',
                    '8',
                    'Total Peminjaman',
                  ),
                  _buildStatCard(
                    'assets/images/total_laporan.png',
                    '32',
                    'Total Laporan',
                  ),
                  _buildStatCard(
                    'assets/images/total_pesan.png',
                    '0',
                    'Total Pesan',
                  ),
                ],
              ),
              const SizedBox(height: 32),

              const Text(
                'Daftar Barang',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (daftarBarang.isEmpty)
                const Text(
                  'Daftar barang kosong.',
                  style: TextStyle(color: Colors.grey),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: daftarBarang.length,
                  itemBuilder: (context, index) {
                    return _buildBarangCard(daftarBarang[index]);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String imageAsset, String value, String label) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(imageAsset, width: 32, height: 32),
                const SizedBox(width: 12),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
