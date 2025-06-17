import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class CreateNewPasswordScreen extends StatefulWidget {
  final String resetToken;

  const CreateNewPasswordScreen({super.key, required this.resetToken});

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submitNewPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    final url = Uri.parse('https://classiflyapi20250531093133-gkdmchbqe6gdanf5.canadacentral-01.azurewebsites.net/api/Auth/reset-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': widget.resetToken,
          'newPassword': _passwordController.text,
        }),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil diubah!'), backgroundColor: Colors.green),
        );
        // Kembali ke halaman login, hapus semua halaman sebelumnya dari tumpukan
        context.go('/login');
      } else {
        setState(() {
          _errorMessage = responseBody['message'] ?? 'Gagal mereset password.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal terhubung ke server.';
      });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Password Baru', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text('Masukkan Password Baru', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 40),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password Baru', border: OutlineInputBorder()),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return 'Password minimal harus 8 karakter.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Konfirmasi Password', border: OutlineInputBorder()),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Password tidak cocok.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              SizedBox(

                width: double.infinity,
                  child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                          onPressed: _submitNewPassword,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: const Color(0xFF2F80ED),
                          ),
                          child: const Text(
                            'Simpan Password',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}