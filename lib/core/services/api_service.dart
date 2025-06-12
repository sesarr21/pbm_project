import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../models/kategori.dart';

class ApiService {
  static const String baseUrl =
      'https://classiflyapi20250531093133-gkdmchbqe6gdanf5.canadacentral-01.azurewebsites.net/api';

  // Fungsi login
  static Future<Map<String, dynamic>?> login(
    String username,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/Auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // Fungsi tambah barang dengan JSON body (gambar base64)
  static Future<bool> tambahBarang({
    required String token,
    required String nama,
    required int kategoriId,
    required int kuantitas,
    required String deskripsi,
    required File? gambar,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/Barang');
      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      // Isi field text
      request.fields['Name'] = nama;
      request.fields['CategoryId'] = kategoriId.toString();
      request.fields['Quantity'] = kuantitas.toString();
      request.fields['Description'] = deskripsi;

      // Isi file image
      if (gambar != null) {
        var stream = http.ByteStream(gambar.openRead());
        var length = await gambar.length();
        var multipartFile = http.MultipartFile(
          'ImageFile',
          stream,
          length,
          filename: gambar.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        // Baca response body error (optional)
        var respStr = await response.stream.bytesToString();
        print('Error tambahBarang: ${response.statusCode}');
        print('Response body: $respStr');
        return false;
      }
    } catch (e) {
      print('Exception tambahBarang: $e');
      return false;
    }
  }

  static Future<List<dynamic>?> fetchBarang(String token) async {
    try {
      var url = Uri.parse('$baseUrl/Barang');
      var response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Fetch barang gagal: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception fetchBarang: $e');
      return null;
    }
  }

  static Future<bool> hapusBarang({
    required String token,
    required int id,
  }) async {
    try {
      var url = Uri.parse('$baseUrl/Barang/$id');
      var response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('Gagal hapus barang: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception hapusBarang: $e');
      return false;
    }
  }

  static Future<List<Kategori>> fetchKategori(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Category'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Kategori.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat kategori');
    }
  }

  static Future<bool> editBarang({
    required String token,
    required int id,
    required String nama,
    required int kategoriId,
    required int kuantitas,
    required String deskripsi,
    File? gambar,
    required String existingImageUrl,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/barang/$id');
      var request =
          http.MultipartRequest('PUT', uri)
            ..headers['Authorization'] = 'Bearer $token'
            ..fields['Name'] = nama
            ..fields['CategoryId'] = kategoriId.toString()
            ..fields['Quantity'] = kuantitas.toString()
            ..fields['Description'] = deskripsi
            ..fields['ExistingImageUrl'] = existingImageUrl;

      if (gambar != null) {
        request.files.add(
          await http.MultipartFile.fromPath('ImageFile', gambar.path),
        );
      } else {
        // Kirim dummy file kosong agar field ImageFile tetap ada
        request.files.add(
          http.MultipartFile.fromBytes('ImageFile', [], filename: 'empty.jpg'),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {
        var body = await response.stream.bytesToString();
        print('Edit failed: ${response.statusCode} $body');
        return false;
      }
    } catch (e) {
      print('Edit exception: $e');
      return false;
    }
  }
}
