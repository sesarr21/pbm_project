import 'package:flutter/material.dart';

class PeminjamanBarang {
  final int itemId;
  final String itemName;
  final int quantity;

  PeminjamanBarang({
    required this.itemId,
    required this.itemName,
    required this.quantity,
  });

  factory PeminjamanBarang.fromJson(Map<String, dynamic> json) {
    return PeminjamanBarang(
      itemId: json['itemId'] as int,
      itemName: json['itemName'] as String,
      quantity: json['quantity'] as int,
    );
  }
}

// Enum untuk mempermudah pengelolaan status
enum PeminjamanStatus {
  approved,
  pending,
  rejected,
}

class Peminjaman {
  final int id;
  final DateTime borrowDate;
  final DateTime? returnDate;
  final PeminjamanStatus status;
  final String? adminMessage;
  final String location;
  final String userName;
  final List<PeminjamanBarang> borrowItems; 

  Peminjaman({
    required this.id,
    required this.borrowDate,
    this.returnDate,
    required this.status,
    this.adminMessage,
    required this.location,
    required this.userName,
    required this.borrowItems,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    // Parsing list 'borrowItems'
    var itemsList = json['borrowItems'] as List;
    List<PeminjamanBarang> parsedItems = itemsList.map((i) => PeminjamanBarang.fromJson(i)).toList();
    
    // Cek untuk returnDate yang default/null
    DateTime? parsedReturnDate;
    if (json['returnDate'] != null && json['returnDate'] != '0001-01-01T00:00:00') {
      parsedReturnDate = DateTime.parse(json['returnDate'] as String);
    }

    return Peminjaman(
      id: json['id'] as int,
      borrowDate: DateTime.parse(json['borrowDate'] as String),
      returnDate: parsedReturnDate,
      status: _parseStatus(json['status'] as String),
      adminMessage: json['adminMessage'] as String?,
      location: json['location'] as String,
      userName: json['userName'] as String,
      borrowItems: parsedItems,
    );
  }

  // Helper function untuk mengubah String status dari API menjadi Enum
  static PeminjamanStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return PeminjamanStatus.approved;
      case 'rejected':
        return PeminjamanStatus.rejected;
      case 'pending':
      default:
        return PeminjamanStatus.pending;
    }
  }

  // Helper untuk mendapatkan warna berdasarkan status
  Color get statusColor {
    switch (status) {
      case PeminjamanStatus.approved:
        return Colors.green;
      case PeminjamanStatus.pending:
        return Colors.orange;
      case PeminjamanStatus.rejected:
        return Colors.red;
    }
  }

  // Helper untuk mendapatkan ikon berdasarkan status
  IconData get statusIcon {
    switch (status) {
      case PeminjamanStatus.approved:
        return Icons.check_circle;
      case PeminjamanStatus.pending:
        return Icons.hourglass_empty;
      case PeminjamanStatus.rejected:
        return Icons.cancel;
    }
  }

  // Helper untuk mendapatkan teks berdasarkan status
  String get statusText {
    switch (status) {
      case PeminjamanStatus.approved:
        return 'Approved';
      case PeminjamanStatus.pending:
        return 'Pending';
      case PeminjamanStatus.rejected:
        return 'Rejected';
    }
  }
}