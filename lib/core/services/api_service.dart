import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import semua model data Anda di sini
import '../../models/notifikasi.dart';
import '../../models/peminjaman_dto.dart';
import '../../models/kategori.dart';
import '../../models/peminjaman.dart';

class ApiService {
  final Dio _dio = Dio();
  static const String baseUrl =
      'https://classiflyapi20250531093133-gkdmchbqe6gdanf5.canadacentral-01.azurewebsites.net/api';

  ApiService() {
    // Interceptor ini akan secara otomatis menambahkan 'Authorization' header
    // ke SEMUA request yang dibuat menggunakan instance _dio
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  // REFAKTOR: Tidak lagi static, tidak perlu token
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/Auth/login',
        data: {'username': username, 'password': password},
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      print('Error login: ${e.response?.data}');
      return null;
    }
  }

  // REFAKTOR: Tidak lagi static, tidak perlu token, menggunakan FormData dari Dio
  Future<bool> tambahBarang({
    required String nama,
    required int kategoriId,
    required int kuantitas,
    required String deskripsi,
    required File? gambar,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'Name': nama,
        'CategoryId': kategoriId,
        'Quantity': kuantitas,
        'Description': deskripsi,
        if (gambar != null)
          'ImageFile': await MultipartFile.fromFile(
            gambar.path,
            filename: gambar.path.split('/').last,
          ),
      });

      final response = await _dio.post(
        '$baseUrl/Barang',
        data: formData,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      print('--- DIO ERROR ---');
      print('Error tambahBarang: ${e.response?.data}');
      print('URL: ${e.requestOptions.uri}');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Error Type: ${e.type}');
      print('--- END DIO ERROR ---');
      return false;
    }
  }

  // REFAKTOR: Tidak lagi static, tidak perlu token
  Future<List<dynamic>?> fetchBarang() async {
    try {
      final response = await _dio.get('$baseUrl/Barang');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      print('--- DIO ERROR ---');
      print('Error fetchBarang: ${e.response?.data}');
      print('URL: ${e.requestOptions.uri}');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Error Type: ${e.type}');
      print('--- END DIO ERROR ---');
      return null;
    }
  }
  
  // REFAKTOR: Tidak lagi static, tidak perlu token
  Future<bool> hapusBarang({required int id}) async {
    try {
      final response = await _dio.delete('$baseUrl/Barang/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      print('--- DIO ERROR ---');
      print('Error hapusBarang: ${e.response?.data}');
      
      print('URL: ${e.requestOptions.uri}');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Error Type: ${e.type}');
      print('--- END DIO ERROR ---');
      return false;
    }
  }

  // REFAKTOR: Tidak lagi static, tidak perlu token
  Future<List<Kategori>> fetchKategori() async {
    try {
      final response = await _dio.get('$baseUrl/Category');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => Kategori.fromJson(item)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('--- DIO ERROR ---');
      print('Error fetchKategori: ${e.response?.data}');
      
      print('URL: ${e.requestOptions.uri}');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Error Type: ${e.type}');
      print('--- END DIO ERROR ---');
      throw Exception('Gagal memuat kategori');
    }
  }

  // REFAKTOR: Tidak lagi static, tidak perlu token, menggunakan FormData dari Dio
  Future<bool> editBarang({
    required int id,
    required String nama,
    required int kategoriId,
    required int kuantitas,
    required String deskripsi,
    File? gambar,
    required String existingImageUrl,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'Name': nama,
        'CategoryId': kategoriId,
        'Quantity': kuantitas,
        'Description': deskripsi,
        'ExistingImageUrl': existingImageUrl,
        if (gambar != null)
          'ImageFile': await MultipartFile.fromFile(
            gambar.path,
            filename: gambar.path.split('/').last,
          ),
      });

      final response = await _dio.put(
        '$baseUrl/barang/$id',
        data: formData,
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('--- DIO ERROR ---');
      print('Error editBarang: ${e.response?.data}');
      
      print('URL: ${e.requestOptions.uri}');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Error Type: ${e.type}');
      print('--- END DIO ERROR ---');
      return false;
    }
  }

  // Fungsi ini sudah benar menggunakan _dio
  Future<bool> submitBorrowRequest(CreateBorrowRequestDto borrowRequest) async {
    try {
      final response = await _dio.post(
        '$baseUrl/Peminjaman',
        data: borrowRequest.toJson(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      print('--- DIO ERROR ---');
      print('Error saat mengajukan peminjaman.');
      print('URL: ${e.requestOptions.uri}');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Error Type: ${e.type}');
      print('--- END DIO ERROR ---');
      return false;
    }
  }

  // Fungsi ini sudah benar menggunakan _dio
  Future<List<Peminjaman>> getPeminjamanList() async {
    try {
      // Endpoint Anda sudah benar: /Peminjaman/user
      final response = await _dio.get('$baseUrl/Peminjaman/user');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        // --- PERBAIKAN DI SINI ---
        // Gunakan Peminjaman.fromJson, bukan DTO.
        return data.map((item) => Peminjaman.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('--- DIO ERROR getPeminjamanList ---');
      print('Error getPeminjamanList: ${e.response?.data}');
      return [];
    }
  }


  Future<List<Peminjaman>> getSemuaPeminjaman() async {
    try {

      final response = await _dio.get('$baseUrl/Peminjaman');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => Peminjaman.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error getSemuaPeminjaman: ${e.response?.data}');
      return [];
    }
  }

  Future<bool> updateStatusPeminjaman({
    required int peminjamanId,
    required String status,
    required String adminMessage,
  }) async {
    try {
      // API biasanya menggunakan method PUT atau PATCH untuk update
      final response = await _dio.put(
        '$baseUrl/Peminjaman/$peminjamanId/status', // Contoh endpoint
        data: {
          'status': status,
          'adminMessage': adminMessage,
        },
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Error updateStatusPeminjaman: ${e.response?.data}');
      return false;
    }
  }

  Future<List<Notifikasi>> getNotifikasi() async {
  try {
    final response = await _dio.get('$baseUrl/Notifikasi');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((item) => Notifikasi.fromJson(item)).toList();
    }
    return [];
  } on DioException catch (e) {
    print('Error getNotifikasi: ${e.response?.data}');
    return [];
  }
}
}