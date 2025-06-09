import 'package:flutter/material.dart';

class DetailBarangPage extends StatelessWidget {
  final Map<String, dynamic> barang;

  const DetailBarangPage({super.key, required this.barang});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Barang')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar full width
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: Image.network(
                  barang['imageUrl'] ?? '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                ),
              ),
            ),

            // Konten detail
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    barang['name'] ?? '-',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${barang['description'] ?? '-'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Kategori',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${barang['categoryName'] ?? '-'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Kuantitas',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${barang['quantity'] ?? '-'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
