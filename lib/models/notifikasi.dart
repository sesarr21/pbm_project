class Notifikasi {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  Notifikasi({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory Notifikasi.fromJson(Map<String, dynamic> json) {
    return Notifikasi(
      id: json['id'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['isRead'] as bool? ?? false, 
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}