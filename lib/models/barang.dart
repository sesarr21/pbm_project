class Barang {
  final int id;
  final String name;
  final int categoryId;
  final int quantity;
  final String description;
  final String imageUrl;

  Barang({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.quantity,
    required this.description,
    required this.imageUrl,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      quantity: json['quantity'] ?? 0,
      description: json['description'] ?? '',
      categoryId: json['categoryId'] ?? 0,
    );
  }
}
