// Model ini merepresentasikan struktur JSON yang akan dikirim ke API

// Kelas untuk item di dalam list "items"
class BorrowItemDto {
  final int itemId;
  final int quantity;

  BorrowItemDto({required this.itemId, required this.quantity});

  // Fungsi untuk mengubah objek Dart menjadi Map (yang akan di-encode ke JSON)
  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'quantity': quantity,
    };
  }
}

// Kelas untuk seluruh body request
class CreateBorrowRequestDto {
  final DateTime borrowDate;
  final String location;
  final double latitude;
  final double longitude;
  final List<BorrowItemDto> items;

  CreateBorrowRequestDto({
    required this.borrowDate,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.items,
  });

  // Fungsi untuk mengubah objek Dart menjadi Map (yang akan di-encode ke JSON)
  Map<String, dynamic> toJson() {
    return {
      // "id" tidak perlu dikirim karena akan di-generate oleh backend
      'borrowDate': borrowDate.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      // Mengubah list objek BorrowItemDto menjadi list Map
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}