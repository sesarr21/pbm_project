import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import semua model data Anda di sini
import '../../models/notifikasi.dart';
import '../../models/peminjaman_dto.dart';
import '../../models/kategori.dart';
import '../../models/peminjaman.dart';
import '../../models/laporan_kerusakan.dart';

class ApiService {
  final Dio _dio = Dio();
  static const String baseUrl =
      'https://classiflyapi20250531093133-gkdmchbqe6gdanf5.canadacentral-01.azurewebsites.net/api';

  ApiService() {

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


  Future<List<Peminjaman>> getPeminjamanList() async {
    try {
      final response = await _dio.get('$baseUrl/Peminjaman/user');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        return data.map((item) => Peminjaman.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('--- DIO ERROR getPeminjamanList ---');
      print('Error getPeminjamanList: ${e.response?.data}');
      return [];
    }
  }

  Future<int> getTotalUsersCount() async {
    try {

      final response = await _dio.get('$baseUrl/Auth/users/count');
      
      return response.data['totalUsers'];

    } on DioException catch (e) {

      throw Exception('Gagal memuat jumlah total pengguna: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
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

      final response = await _dio.put(
        '$baseUrl/Peminjaman/$peminjamanId/status', 
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

  Future<bool> hapusNotifikasi(int notifikasiId) async {
  try {
   
    final response = await _dio.delete('$baseUrl/Notifikasi/$notifikasiId');
    return response.statusCode == 200 || response.statusCode == 204;
  } on DioException catch (e) {
    print('Error hapusNotifikasi: ${e.response?.data}');
    return false;
  }
}

  Future<bool> submitLaporanKerusakan({
    required int borrowRequestId,
    required String description,
    required File imageFile,
    required String location,
    double? latitude,
    double? longitude,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'BorrowRequestId': borrowRequestId,
        'Description': description,
        'Location': location,
        'Latitude': latitude ?? 0.0,
        'Longitude': longitude ?? 0.0,
        'ImageFile': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

   
      final response = await _dio.post('$baseUrl/Laporan', data: formData);
      return response.statusCode == 201 || response.statusCode == 200;

    } on DioException catch (e) {
      print('Error submitLaporanKerusakan: ${e.response?.data}');
      return false;
    }
  }

  Future<List<LaporanKerusakan>> getSemuaLaporanKerusakan() async {
    try {
      final response = await _dio.get('$baseUrl/Laporan');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => LaporanKerusakan.fromJson(item)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error getSemuaLaporanKerusakan: ${e.response?.data}');
      return [];
    }
  }
 
  Future<bool> updateStatusLaporan(int laporanId, String newStatus , String adminMessage) async {
    try {
      final response = await _dio.put(
        '$baseUrl/Laporan/$laporanId/status',
        data: {
        'status': newStatus,
        'adminMessage': adminMessage, 
      },
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Error updateStatusLaporan: ${e.response?.data}');
      return false;
    }
  }

  Future<bool> tambahKategori(String nama) async {
    try {
      final response = await _dio.post(
        '$baseUrl/Category',
        data: {'name': nama},
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } on DioException catch (e) {
      print('Error tambahKategori: ${e.response?.data}');
      return false;
    }
  }

  Future<bool> editKategori(int id, String namaBaru) async {
    try {
      final response = await _dio.put(
        '$baseUrl/Category/$id',
        data: {'id': id, 'name': namaBaru},
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      print('Error editKategori: ${e.response?.data}');
      return false;
    }
  }

  Future<bool> hapusKategori(int id) async {
    try {
      final response = await _dio.delete('$baseUrl/Category/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      print('Error hapusKategori: ${e.response?.data}');
      return false;
    }
  }

  Future<Map<String, dynamic>> createUserByAdmin({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/Auth/admin/create-user', 
        data: {
          'username': username,
          'email': email,
          'password': password,
          'fullName': fullName,
          'role': role,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Gagal membuat user.');
      }
      throw Exception('Gagal terhubung ke server: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan yang tidak diketahui: $e');
    }
  }

}