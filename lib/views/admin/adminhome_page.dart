import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_service.dart';
import 'barang/tambah_page.dart';
import 'barang/detailbarang_page.dart';
import 'tambah_user/tambah_user_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  List<dynamic> daftarBarang = [];
  bool isLoading = false;
  final ApiService _apiService = ApiService();

  int _totalBarang = 0;
  int _totalPeminjaman = 0;
  int _totalLaporan = 0;
  int _totalUser = 0;

  bool _isLoadingStats = true;
  bool _isLoadingList = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // Fungsi untuk mengambil semua data dashboard secara paralel
  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoadingStats = true;
      _isLoadingList = true;
    });

    try {
      // Gunakan Future.wait untuk menjalankan semua API call secara bersamaan
      final results = await Future.wait([
        _apiService.fetchBarang(),
        _apiService.getSemuaPeminjaman(),
        _apiService.getSemuaLaporanKerusakan(),
        _apiService.getTotalUsersCount(),
      ]);

      // Setelah semua selesai, update state dengan hasilnya
      if (mounted) {
        setState(() {
          // Hasil untuk kartu statistik
          daftarBarang = results[0] as List<dynamic>? ?? [];
          _totalBarang = daftarBarang.length;
          _totalPeminjaman = (results[1] as List).length;
          _totalLaporan = (results[2] as List).length;
          _totalUser = results[3] as int;

          // Matikan semua loading
          _isLoadingStats = false;
          _isLoadingList = false;
        });
      }
    } catch (e) {
      print("Error fetching dashboard data: $e");
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
          _isLoadingList = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat data dashboard.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchBarangOnly() async {
    setState(() => _isLoadingList = true);
    final data = await _apiService.fetchBarang();
    if (mounted) {
      setState(() {
        daftarBarang = data ?? [];
        _totalBarang = daftarBarang.length; // Update juga total barang
        _isLoadingList = false;
      });
    }
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
          _fetchBarangOnly();
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
          ).then((isSuccess) {
            if (isSuccess == true) {
              _fetchDashboardData();
            } // Refresh data setelah menambahkan
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
                    icon: const Icon(Icons.person_add_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddUserScreen(),
                        ),
                      );
                    },
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

              // GridView untuk Statistik
              _isLoadingStats
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.4,
                    children: [
                      _buildStatCard(
                        'assets/images/total_barang.png',
                        _totalBarang.toString(),
                        'Total Barang',
                      ),
                      _buildStatCard(
                        'assets/images/total_peminjaman.png',
                        _totalPeminjaman.toString(),
                        'Total Peminjaman',
                      ),
                      _buildStatCard(
                        'assets/images/total_laporan.png',
                        _totalLaporan.toString(),
                        'Total Laporan',
                      ),
         
                      _buildStatCard(
                        'assets/images/total_user.png', 
                        _totalUser.toString(),
                        'Total User',
                      ),
                    ],
                  ),
              const SizedBox(height: 32),

              const Text(
                'Daftar Barang',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _isLoadingList
                  ? const Center(child: CircularProgressIndicator())
                  : daftarBarang.isEmpty
                  ? const Text(
                    'Daftar barang kosong.',
                    style: TextStyle(color: Colors.grey),
                  )
                  : ListView.builder(
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
