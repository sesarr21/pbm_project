import 'package:flutter/material.dart';
import 'package:classifly/views/auth/welcome_page.dart';

void main() {
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
