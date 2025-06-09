import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

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
}
