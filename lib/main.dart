import 'package:flutter/material.dart';
import 'package:classifly/views/auth/welcome_page.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async { // 2. Jadikan fungsi main sebagai async
  // 3. Pastikan binding Flutter sudah siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Inisialisasi data locale untuk bahasa Indonesia ('id_ID')
  await initializeDateFormatting('id_ID', null);

  // 5. Jalankan aplikasi seperti biasa
  runApp(const ClassiflyApp());
}

class ClassiflyApp extends StatelessWidget {
  const ClassiflyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowMaterialGrid: false,
      title: 'Classifly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const WelcomePage(),
    );
  }
}
