import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/mood_provider.dart';
import 'ui/auth/login_screen.dart';
import 'ui/home/home_screen.dart';
import 'ui/auth/pairing_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Lỗi Firebase: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Khởi tạo AuthProvider
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
      ],
      child: MaterialApp(
        title: 'Love Sync',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false, // Tắt cái banner Debug cho đẹp
        // 👇 LOGIC ĐIỀU HƯỚNG TỰ ĐỘNG
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            // 1. Loading
            if (auth.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // 2. Chưa login -> Login
            if (auth.user == null) {
              return const LoginScreen();
            }

            // 3. Đã login nhưng CHƯA có coupleId -> Màn hình ghép đôi
            if (auth.coupleId == null) {
              return const PairingScreen();
            }

            // 4. Đã login và có coupleId -> Vào nhà
            return const HomeScreen();
          },
        ),

        routes: {
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.home: (context) => const HomeScreen(),
        },
      ),
    );
  }
}
