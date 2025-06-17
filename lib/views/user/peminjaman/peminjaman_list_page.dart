import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../../../models/peminjaman.dart';
import 'detail_peminjaman_page.dart';

class PeminjamanListPage extends StatefulWidget {
  const PeminjamanListPage({super.key, required int initialIndex});

  @override
  State<PeminjamanListPage> createState() => _PeminjamanListPageState();
}

class _PeminjamanListPageState extends State<PeminjamanListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  late Future<List<Peminjaman>> _peminjamanFuture;
  List<Peminjaman> _allPeminjaman = [];
  List<Peminjaman> _filteredPeminjaman = [];

  final List<String> _tabs = ["All", "Approved", "Pending", "Rejected"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _peminjamanFuture = _loadPeminjaman();
    _tabController.addListener(_handleTabSelection);
  }

  Future<List<Peminjaman>> _loadPeminjaman() async {
    final data = await _apiService.getPeminjamanList();
    setState(() {
      _allPeminjaman = data;
      _filteredPeminjaman = data; // Awalnya tampilkan semua
    });
    return data;
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      return;
    }
    final selectedTab = _tabs[_tabController.index].toLowerCase();
    setState(() {
      if (selectedTab == "all") {
        _filteredPeminjaman = _allPeminjaman;
      } else {
        _filteredPeminjaman = _allPeminjaman
            .where((p) => p.status.toString().split('.').last == selectedTab)
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Peminjaman',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false, // Menghilangkan tombol back
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.blue,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.blue,
          ),
          tabs: _tabs.map((String tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: FutureBuilder<List<Peminjaman>>(
        future: _peminjamanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data peminjaman.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _filteredPeminjaman.length,
            itemBuilder: (context, index) {
              final peminjaman = _filteredPeminjaman[index];
              return _buildPeminjamanCard(peminjaman);
            },
          );
        },
      ),
    );
  }

  Widget _buildPeminjamanCard(Peminjaman peminjaman) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman detail saat card diklik
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPeminjamanPage(peminjaman: peminjaman),
          ),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Peminjaman: ${peminjaman.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Icon(Icons.expand_less), // Chevron icon
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.receipt_long, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy').format(peminjaman.borrowDate),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(peminjaman.statusIcon, color: peminjaman.statusColor, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          peminjaman.statusText,
                          style: TextStyle(
                              color: peminjaman.statusColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
    
  }
}