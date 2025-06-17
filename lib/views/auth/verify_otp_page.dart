import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _verifyOtp() async {
    if (_pinController.text.length != 6) {
      setState(() {
        _errorMessage = 'Harap masukkan 6 digit OTP.';
      });
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    final url = Uri.parse('https://classiflyapi20250531093133-gkdmchbqe6gdanf5.canadacentral-01.azurewebsites.net/api/Auth/verify-otp');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': widget.email,
          'otp': _pinController.text,
        }),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        final String resetToken = responseBody['resetToken'];
        // Jika sukses, pindah ke halaman buat password baru sambil membawa token reset
        context.push('/create-new-password', extra: resetToken);
      } else {
        setState(() {
          _errorMessage = responseBody['message'] ?? 'Gagal memverifikasi OTP.';
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

  Future<void> _resendOtp() async {

     ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meminta ulang OTP...')),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi OTP', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Text('Masukkan Kode OTP', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text('Kode 6 digit telah dikirim ke\n${widget.email}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 40),
            
            // Pinput Widget
            Pinput(
              controller: _pinController,
              length: 6,
              autofocus: true,
              onCompleted: (pin) => _verifyOtp(),
              defaultPinTheme: PinTheme(
                width: 56,
                height: 56,
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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
                          onPressed: _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: const Color(0xFF2F80ED),
                          ),
                          child: const Text(
                            'Verifikasi',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Tidak menerima kode?"),
                TextButton(
                  onPressed: _resendOtp,
                  child: const Text("Kirim Ulang"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}