import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/laporan_kerusakan.dart';
import '../../../core/services/api_service.dart';

class AdminDetailLaporanPage extends StatefulWidget {
  final LaporanKerusakan laporan;
  const AdminDetailLaporanPage({super.key, required this.laporan});

  @override
  State<AdminDetailLaporanPage> createState() => _AdminDetailLaporanPageState();
}

class _AdminDetailLaporanPageState extends State<AdminDetailLaporanPage> {
  late LaporanKerusakan _laporan;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _laporan = widget.laporan;
  }

  void _showUpdateStatusDialog() {

    final messageController = TextEditingController();
    String selectedStatus = _laporan.status; 

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Ubah Status Laporan #${_laporan.id}'),
   
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Status Laporan'),
                    DropdownButton<String>(
                      value: selectedStatus,
                      isExpanded: true,
                      items: ['Pending', 'In Progress', 'Resolved'].map((status) {
                        return DropdownMenuItem(value: status, child: Text(status));
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
                    
                    const Text('Pesan Admin (Wajib Diisi)'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Tulis pesan atau catatan...',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () async {
                    // 4. Kirim status DAN pesan ke API
                    final success = await _apiService.updateStatusLaporan(
                      _laporan.id, 
                      selectedStatus, 
                      messageController.text, // <-- Ambil teks dari controller
                    );
                    
                    if (success && mounted) {
                      Navigator.pop(context, true); // Tutup dialog dan kirim sinyal refresh
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal memperbarui status. Pastikan pesan diisi.'), backgroundColor: Colors.red),
                      );
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Laporan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)),
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
                  'Laporan: #${_laporan.id}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 32),
                
                // Menampilkan Foto Kerusakan
                _buildSectionTitle('Foto Kerusakan'),
                const SizedBox(height: 12),
                _buildImage(_laporan.imageUrl),
                const SizedBox(height: 16),

                // Menampilkan Keterangan
                _buildSectionTitle('Keterangan'),
                const SizedBox(height: 4),
                Text(_laporan.description, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 24),

                // Menampilkan Detail Tambahan
                _buildDetailRow(Icons.person_outline, 'Nama Pelapor', _laporan.userName),
                _buildDetailRow(Icons.location_on_outlined, 'Lokasi Kejadian', _laporan.location),
                _buildDetailRow(Icons.calendar_today_outlined, 'Tanggal Lapor', DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(_laporan.tanggalLapor.toLocal())),
                
                const Divider(height: 32),
                
                // Menampilkan Status Laporan
                _buildStatus(_laporan.status),
              ],
            ),
          ),
        ),
      ),
       floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUpdateStatusDialog,
        label: const Text('Ubah Status', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.edit, color: Colors.white,),
        backgroundColor: const Color(0xFF2F80ED)
      ),
    );
  }

  // --- WIDGET HELPER UNTUK UI YANG LEBIH BERSIH ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 200,
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                children: [
                  TextSpan(text: '$title: '),
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(String status) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'resolved':
        statusColor = Colors.green;
        break;
      case 'in progress':
        statusColor = Colors.orange;
        break;
      case 'pending':
      default:
        statusColor = Colors.blue;
        break;
    }
    return Row(
      children: [
        const Text('Status Laporan: ', style: TextStyle(fontSize: 16)),
        Text(
          status,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: statusColor),
        ),
      ],
    );
  }
}