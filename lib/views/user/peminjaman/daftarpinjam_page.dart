import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';
import '../../../models/peminjaman_dto.dart';

class DaftarPinjamPage extends StatefulWidget {
  final List<dynamic> daftarBarangPinjam;

  const DaftarPinjamPage({super.key, required this.daftarBarangPinjam});

  @override
  State<DaftarPinjamPage> createState() => _DaftarPinjamPageState();
}

class _DaftarPinjamPageState extends State<DaftarPinjamPage> {
  bool lokasiAktif = false;
  Position? currentPosition;
  bool _isFetchingLocation = false;

  
  late List<Map<String, dynamic>> barangList;

  
  Map<int, bool> checkedMap = {};

  bool _isLoading = false; 
  final ApiService _apiService = ApiService(); 

  @override
  void initState() {
    super.initState();
    barangList =
        widget.daftarBarangPinjam
            .map<Map<String, dynamic>>(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();

    for (int i = 0; i < barangList.length; i++) {
      checkedMap[i] = false;
    }
  }

  int get totalBarang {
    int total = 0;
    for (int i = 0; i < barangList.length; i++) {
      if (checkedMap[i] == true) {
        total += (barangList[i]['selectedQuantity'] ?? 0) as int;
      }
    }
    return total;
  }

  Future<void> _aktifkanLokasi(bool val) async {
    setState(() {
    lokasiAktif = val;
    if (val) {
      _isFetchingLocation = true; 
      }
    });
    
    if (val) {
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Layanan lokasi tidak aktif')),
          );
          setState(() {
            lokasiAktif = false;
          });
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak')));
            setState(() {
              lokasiAktif = false;
            });
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin lokasi ditolak permanen')),
          );
          setState(() {
            lokasiAktif = false;
          });
          return;
        }

        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        setState(() {
          currentPosition = position;
        });

        debugPrint(
          'Lokasi saat ini: ${position.latitude}, ${position.longitude}',
        );
      } finally {
      setState(() {
        _isFetchingLocation = false; 
      });
    }
      
    } else {
      setState(() {
        currentPosition = null;
      });
    }
  }

  void updateQuantity(int index, bool increment) {
    setState(() {
      int current = barangList[index]['selectedQuantity'] ?? 0;
      int maxQty = barangList[index]['quantity'] ?? 1;

      if (increment) {
        if (current < maxQty) {
          barangList[index]['selectedQuantity'] = current + 1;

          if (checkedMap[index] != true) {
            checkedMap[index] = true;
          }
        }
      } else {
        if (current > 0) {
          barangList[index]['selectedQuantity'] = current - 1;
          if (barangList[index]['selectedQuantity'] == 0) {
            checkedMap[index] = false;
            barangList.removeAt(index);

            Map<int, bool> newChecked = {};
            for (int i = 0; i < barangList.length; i++) {
              newChecked[i] = checkedMap[i >= index ? i + 1 : i] ?? false;
            }
            checkedMap = newChecked;
          }
        }
      }
    });
  }

  void toggleCheck(int index, bool? val) {
    setState(() {
      checkedMap[index] = val ?? false;

      if (!checkedMap[index]!) {
        barangList[index]['selectedQuantity'] = 0;
      } else {

        if ((barangList[index]['selectedQuantity'] ?? 0) == 0) {
          barangList[index]['selectedQuantity'] = 1;
        }
      }
    });
  }

  Future<void> _handleAjukanPeminjaman() async {
    setState(() { _isLoading = true; });

    final List<BorrowItemDto> selectedItemsDto = [];
    for (int i = 0; i < barangList.length; i++) {
      if (checkedMap[i] == true && (barangList[i]['selectedQuantity'] ?? 0) > 0) {
        selectedItemsDto.add(
          BorrowItemDto(
 
            itemId: barangList[i]['id'] as int, 
            quantity: barangList[i]['selectedQuantity'] as int,
          ),
        );
      }
    }

    if (selectedItemsDto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih setidaknya satu barang.')));
      setState(() { _isLoading = false; });
      return;
    }
    
    if (currentPosition == null && lokasiAktif) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mendapatkan lokasi. Mohon coba lagi.')));
        setState(() { _isLoading = false; });
        return;
    }

    // 2. Buat objek DTO utama
    final borrowRequestDto = CreateBorrowRequestDto(
      borrowDate: DateTime.now().toUtc(), 
      location: lokasiAktif ? "Sekolah" : "Tidak Diketahui",
      latitude: lokasiAktif ? currentPosition!.latitude : 0.0,
      longitude: lokasiAktif ? currentPosition!.longitude : 0.0,
      items: selectedItemsDto,
    );


    final bool success = await _apiService.submitBorrowRequest(borrowRequestDto);

    setState(() { _isLoading = false; });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Peminjaman berhasil diajukan!'),
          backgroundColor: Colors.green,
        ),
      );

      context.go('/peminjaman-list', extra: 1);

    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengajukan peminjaman. Coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context, barangList);
          },
        ),
        title: const Text(
          'Daftar Barang',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child:
                barangList.isEmpty
                    ? const Center(
                      child: Text(
                        'Belum ada barang dipinjam',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: barangList.length,
                      itemBuilder: (context, index) {
                        final barang = barangList[index];
                        final selectedQty = barang['selectedQuantity'] ?? 0;
                        final maxQty = barang['quantity'] ?? 1;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Checkbox
                                Checkbox(
                                  value: checkedMap[index] ?? false,
                                  onChanged: (val) => toggleCheck(index, val),
                                ),

                                // Foto barang (contoh pakai placeholder)
                                Container(
                                  width: 60,
                                  height: 60,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image:
                                          barang['imageUrl'] != null
                                              ? NetworkImage(barang['imageUrl'])
                                              : const AssetImage(
                                                    'assets/images/placeholder.png',
                                                  )
                                                  as ImageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                                // Nama barang & jumlah di kanan foto
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        barang['name'] ?? '-',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Button min, angka, plus di ujung kanan bawah
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      onPressed:
                                          selectedQty > 0
                                              ? () =>
                                                  updateQuantity(index, false)
                                              : null,
                                    ),
                                    Text(
                                      '$selectedQty',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      onPressed:
                                          selectedQty < maxQty
                                              ? () =>
                                                  updateQuantity(index, true)
                                              : null,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: const Color(0x4D2F80ED),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Aktifkan lokasi anda',
                  style: TextStyle(fontSize: 16),
                ),
                Switch(
                  value: lokasiAktif,
                  onChanged: _aktifkanLokasi,
                  activeColor: const Color(0xFF2F80ED),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('Total Barang: ', style: TextStyle(fontSize: 16)),
                Text(
                  '$totalBarang pcs',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (totalBarang > 0 && !_isLoading && !_isFetchingLocation)
                  ? _handleAjukanPeminjaman
                  : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F80ED),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : _isFetchingLocation 
                      ? const Text('Mencari Lokasi...', style: TextStyle(color: Colors.white))
                      : const Text(
                        'Ajukan Peminjaman',
                          style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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

// Dummy MainPage untuk navigasi, akan kita buat di langkah 5
// class MainPage extends StatelessWidget {
//   final int initialIndex;
//   const MainPage({super.key, this.initialIndex = 0});

//   @override
//   Widget build(BuildContext context) {
//     // Implementasi lengkap ada di langkah 5
//     return PeminjamanListPage(); 
//   }
// }