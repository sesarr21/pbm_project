import 'package:classifly/views/user/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:classifly/views/auth/welcome_page.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'views/admin/admin_dashboard.dart';
import 'views/auth/login_page.dart';
import 'views/auth/lupa_password_page.dart';
import 'views/auth/reset_password_page.dart';
import 'views/auth/verify_otp_page.dart';
import 'views/profil.dart';
import 'views/user/peminjaman/peminjaman_list_page.dart';
import 'views/user/profil/faq_page.dart';
import 'views/user/profil/hubungikami_page.dart';
import 'views/user/profil/informasi_page.dart';
import 'views/user/profil/lokasi_page.dart';
import 'views/user/profil/pengaturan_page.dart';
import 'views/user/userhome_page.dart';

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(const ClassiflyApp());
}

// 1. Buat instance GoRouter di level tertinggi (global)
final GoRouter _router = GoRouter(
  initialLocation: '/welcome', // Tentukan halaman awal
  routes: <RouteBase>[
    GoRoute(
      path: '/welcome', // Route untuk halaman login
      builder: (BuildContext context, GoRouterState state) {
        return const WelcomePage();
      },
    ),
    GoRoute(
      path: '/login', // Route untuk halaman login
      builder: (BuildContext context, GoRouterState state) {
        return const LoginPage();
      },
    ),
    GoRoute(
      path: '/forgot-password', // Route untuk halaman lupa password
      builder: (BuildContext context, GoRouterState state) {
        return const ForgotPasswordScreen();
      },
    ),
    GoRoute(
      path: '/verify-otp', // Route untuk halaman verifikasi OTP
      builder: (BuildContext context, GoRouterState state) {
        final String email = state.extra as String? ?? 'Email tidak ada';
        
        return VerifyOtpScreen(email: email); 
      },
    ),
    GoRoute(
      path: '/create-new-password',
      builder: (context, state) {
        
        final String resetToken = state.extra as String? ?? '';
        if (resetToken.isEmpty) {
          
          return const Scaffold(body: Center(child: Text('Token reset tidak valid.')));
        }
        return CreateNewPasswordScreen(resetToken: resetToken);
      },
    ),

    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        // 'child' akan diisi oleh GoRouter dengan salah satu halaman di bawah ini
        return MainScaffold(child: child);
      },
      routes: <RouteBase>[
        // Halaman-halaman yang akan ditampilkan di dalam cangkang
        GoRoute(
          path: '/home',
          builder: (context, state) => const UserHomePage(), // Pengganti pages[0]
        ),
        GoRoute(
          path: '/peminjaman-list',
          builder: (context, state) {
            final int initialIndex = state.extra as int? ?? 0;
            return PeminjamanListPage(initialIndex: initialIndex); // Pengganti pages[1]
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilPage(), // Pengganti pages[2]
        ),
      ],
    ),

    GoRoute(
      path: '/admin-dashboard',
      builder: (BuildContext context, GoRouterState state) {
        return const AdminDashboard();
      },
    ),
    
    GoRoute(path: '/profile/location', builder: (c, s) => const LocationPage()),
    GoRoute(path: '/settings', builder: (c, s) => const SettingsPage()),
    GoRoute(path: '/information', builder: (c, s) => const InformationPage()),
    GoRoute(path: '/contact-us', builder: (c, s) => const ContactUsPage()),
    GoRoute(path: '/faqs', builder: (c, s) => const FaqsPage()),
  ],
);

class ClassiflyApp extends StatelessWidget {
  const ClassiflyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowMaterialGrid: false,
      title: 'Classifly',
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
    );
  }
}
