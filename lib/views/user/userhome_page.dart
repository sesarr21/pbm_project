import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_service.dart';
import '../../models/notifikasi.dart';
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

  int userId = 0;
  String userName = '';
  List<dynamic> daftarBarang = [];
  bool isLoading = false;
  String searchQuery = '';

  List<Map<String, dynamic>> daftarBarangPinjam = [];
  int _notificationCount = 0; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadUserInfoAndFetchBarang();
  }

  
  Future<void> _loadUserInfoAndFetchBarang() async {
    final prefs = await SharedPreferences.getInstance();

    final tokenExists = prefs.getString('token') != null;
    
    userId = prefs.getInt('Id') ?? 0;
    userName = prefs.getString('username') ?? '';

    if (tokenExists) {
      await _fetchBarang();
    }
  }


  Future<void> _loadInitialData() async {
    setState(() { _isLoading = true; });

    try {
      final results = await Future.wait([
        _apiService.fetchBarang(),      
        _apiService.getNotifikasi(),    
      ]);

      if (mounted) {
        setState(() {
          daftarBarang = results[0] as List<dynamic>? ?? [];
          final notifikasiList = results[1] as List<Notifikasi>? ?? [];
          _notificationCount = notifikasiList.length; 
        });
      }
    } catch (e) {
      print("Error loading initial data: $e");
      // Handle error
    } finally {
      if(mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _fetchBarang() async {
    setState(() {
      isLoading = true;
    });

    final data = await _apiService.fetchBarang();

    if (mounted) {
      setState(() {
        daftarBarang = data ?? [];
        isLoading = false;
      });
    }
  }

  Widget _buildCartIcon(BuildContext context) {
    return Stack(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          tooltip: 'Daftar Pinjam',
          onPressed: () async {
            final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DaftarPinjamPage(
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

        if (daftarBarangPinjam.isNotEmpty)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '${daftarBarangPinjam.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return Stack(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.notifications_none),
          tooltip: 'Notifikasi',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotifikasiPage()),
            ).then((_) {

              _loadInitialData();
            });
          },
        ),

        if (_notificationCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '$_notificationCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

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
                      _buildCartIcon(context),
                      _buildNotificationIcon(context)
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

      
              Text( 
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

