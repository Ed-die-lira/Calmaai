import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/meditation_screen.dart';
import 'screens/diary_screen.dart';
import 'screens/breathing_screen.dart';
import 'screens/community_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/diagnostic_screen.dart';
import 'services/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          // Verificar status de autenticação ao iniciar
          Future.delayed(Duration.zero, () {
            authService.checkAuthStatus();
          });

          return MaterialApp(
            title: 'Calma AI',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => const HomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/meditation': (context) => const MeditationScreen(),
              '/diary': (context) => const DiaryScreen(),
              '/breathing': (context) => const BreathingScreen(),
              '/community': (context) => const CommunityScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/diagnostic': (context) => const DiagnosticScreen(),
            },
          );
        },
      ),
    );
  }
}
