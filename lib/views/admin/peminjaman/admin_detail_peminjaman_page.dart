import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../../../models/peminjaman.dart';

class AdminDetailPeminjamanPage extends StatefulWidget {
  final Peminjaman peminjaman;

  const AdminDetailPeminjamanPage({super.key, required this.peminjaman});

  @override
  State<AdminDetailPeminjamanPage> createState() => _AdminDetailPeminjamanPageState();
}

class _AdminDetailPeminjamanPageState extends State<AdminDetailPeminjamanPage> {
  late Peminjaman _peminjaman;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _peminjaman = widget.peminjaman;
  }
  
  void _showUpdateStatusDialog(BuildContext context) {
    final messageController = TextEditingController(text: _peminjaman.adminMessage);
    String selectedStatus = _peminjaman.status.name; 

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( 
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Peminjaman: #${_peminjaman.id}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ubah Status'),
                    DropdownButton<String>(
                      value: selectedStatus,
                      isExpanded: true,
                      items: PeminjamanStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status.name,
                          child: Text(status.name.substring(0, 1).toUpperCase() + status.name.substring(1)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedStatus = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Tambah Pesan'),
                    TextField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Pesan untuk peminjam...',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String statusTerpilih = selectedStatus;

                    String statusUntukApi = statusTerpilih.substring(0, 1).toUpperCase() + statusTerpilih.substring(1);

                    final success = await _apiService.updateStatusPeminjaman(
                      peminjamanId: _peminjaman.id,
                      status: statusUntukApi,
                      adminMessage: messageController.text,
                    );
                    if (success && mounted) {
                      Navigator.pop(context); 
                      setState(() {
                         _peminjaman = Peminjaman.fromJson({ 
                            ..._peminjaman.toJson(), 
                            'status': selectedStatus,
                            'adminMessage': messageController.text
                         });
                      });
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaftarItem(List<PeminjamanBarang> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list_alt_outlined, color: Colors.grey[600], size: 20),
            const SizedBox(width: 16),
            Text('Daftar Item', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 36.0),
          child: Column(
            children: items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.itemName),
                    Text('${item.quantity} pcs'),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }


  Widget _buildStatus(Peminjaman peminjaman) {
    return Row(
      children: [
        Icon(peminjaman.statusIcon, color: peminjaman.statusColor, size: 28),
        const SizedBox(width: 12),
        Text(
          peminjaman.statusText,
          style: TextStyle(
            color: peminjaman.statusColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Peminjaman', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),)),
      body: SingleChildScrollView(
         padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peminjaman: #${_peminjaman.id}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 32),
                
                
                _buildDetailRow(Icons.person_outline, 'Nama Peminjam', _peminjaman.userName),
                _buildDetailRow(Icons.location_on_outlined, 'Lokasi', _peminjaman.location),
                _buildDetailRow(Icons.calendar_today_outlined, 'Tanggal Peminjaman', DateFormat('dd MMMM yyyy', 'id_ID').format(_peminjaman.borrowDate)),
                const SizedBox(height: 16),
                
                
                _buildDaftarItem(_peminjaman.borrowItems), 
                
                const Divider(height: 32),
                _buildStatus(_peminjaman),
                const SizedBox(height: 16),
                
              
                _buildDetailRow(Icons.message_outlined, 'Pesan Admin', _peminjaman.adminMessage ?? 'Tidak ada pesan'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUpdateStatusDialog(context),
        label: const Text('Edit Status', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.edit, color: Colors.white,),
        backgroundColor: const Color(0xFF2F80ED),
        
      ),
    );
  }
}



// Catatan: Anda perlu menambahkan method toJson() di model Peminjaman
// untuk mempermudah update state seperti contoh di atas.
extension PeminjamanJson on Peminjaman {
  Map<String, dynamic> toJson() => {
        'id': id,
        'borrowDate': borrowDate.toIso8601String(),
        'returnDate': returnDate?.toIso8601String(),
        'status': status.name,
        'adminMessage': adminMessage,
        'location': location,
        'userName': userName,
        'borrowItems': borrowItems.map((e) => {'itemId': e.itemId, 'itemName': e.itemName, 'quantity': e.quantity}).toList(),
      };
}