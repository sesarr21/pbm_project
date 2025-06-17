class LaporanKerusakan {
  final int id;
  final String description;
  final String imageUrl;
  final String userName;
  final String location;
  final DateTime tanggalLapor;
  final String status;
  
  LaporanKerusakan({
    required this.id,
    required this.description,
    required this.imageUrl,
    required this.userName,
    required this.location,
    required this.tanggalLapor,
    required this.status,
  });

  factory LaporanKerusakan.fromJson(Map<String, dynamic> json) {
    return LaporanKerusakan(
      id: json['id'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      userName: json['userName'], 
      location: json['location'],
      tanggalLapor: DateTime.parse(json['createdAt']), 
      status: json['status'],
    );
  }
}