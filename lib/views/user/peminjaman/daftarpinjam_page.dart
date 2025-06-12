import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/api_service.dart';

class DaftarPinjamPage extends StatefulWidget {
  final List<dynamic> daftarBarangPinjam;

  const DaftarPinjamPage({super.key, required this.daftarBarangPinjam});

  @override
  State<DaftarPinjamPage> createState() => _DaftarPinjamPageState();
}

class _DaftarPinjamPageState extends State<DaftarPinjamPage> {
  bool lokasiAktif = false;
  Position? currentPosition;

  // List lokal yang bisa diubah, salinan dari daftarBarangPinjam
  late List<Map<String, dynamic>> barangList;

  // Map untuk track checklist tiap barang, key = index barang di barangList
  Map<int, bool> checkedMap = {};

  @override
  void initState() {
    super.initState();
    // Copy data dari widget ke list lokal supaya bisa diubah
    barangList =
        widget.daftarBarangPinjam
            .map<Map<String, dynamic>>(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();

    // Inisialisasi semua checkbox false
    for (int i = 0; i < barangList.length; i++) {
      checkedMap[i] = false;
    }
  }

  // Total barang berdasarkan checkbox yang aktif dan quantity yang dipilih
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
    });

    if (val) {
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
    } else {
      setState(() {
        currentPosition = null;
      });
    }
  }

  // Fungsi untuk update jumlah barang yang dipilih (min/plus)
  void updateQuantity(int index, bool increment) {
    setState(() {
      int current = barangList[index]['selectedQuantity'] ?? 0;
      int maxQty = barangList[index]['quantity'] ?? 1;

      if (increment) {
        if (current < maxQty) {
          barangList[index]['selectedQuantity'] = current + 1;
          // Jika belum diceklis, langsung ceklis kalau quantity > 0
          if (checkedMap[index] != true) {
            checkedMap[index] = true;
          }
        }
      } else {
        if (current > 0) {
          barangList[index]['selectedQuantity'] = current - 1;
          if (barangList[index]['selectedQuantity'] == 0) {
            // Kalau quantity jadi 0, uncheck dan hapus barang dari list
            checkedMap[index] = false;
            barangList.removeAt(index);

            // Karena hapus item dari list, kita juga harus update key di checkedMap
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

  // Fungsi toggle checklist barang
  void toggleCheck(int index, bool? val) {
    setState(() {
      checkedMap[index] = val ?? false;
      // Kalau checklist false, set quantity ke 0 juga supaya tidak dihitung
      if (!checkedMap[index]!) {
        barangList[index]['selectedQuantity'] = 0;
      } else {
        // Kalau checklist true tapi quantity 0, set ke 1 minimal
        if ((barangList[index]['selectedQuantity'] ?? 0) == 0) {
          barangList[index]['selectedQuantity'] = 1;
        }
      }
    });
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
                onPressed: () {
                  // TODO: Handle ajukan peminjaman ke backend
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F80ED),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
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
