import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Importar configurações do Firebase
import 'firebase_options.dart';

// Importar telas
import 'screens/home_screen.dart';
import 'screens/meditation_screen.dart';
import 'screens/diary_screen.dart';
import 'screens/breathing_screen.dart';
import 'screens/community_screen.dart';

// Importar serviços
import 'services/auth_service.dart';
import 'services/mock_auth_service.dart';

// Importar utilitários
import 'utils/disable_web_plugins.dart';
// Importar fix para Firebase Web
import 'utils/firebase_web_fix.dart';

void main() async {
  // Garantir que os widgets estejam inicializados
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Verificar se estamos na web
    if (kIsWeb) {
      print("Executando na web - Usando serviço de autenticação mock");
      // Desabilitar plugins web problemáticos
      disableWebPlugins();

      // Para web, inicializar Firebase sem autenticação
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      // Para mobile, inicializar normalmente
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("Firebase inicializado com sucesso");
    }

    // Executar o aplicativo com o Provider
    runApp(
      MultiProvider(
        providers: [
          // Usar MockAuthService para web e AuthService para mobile
          ChangeNotifierProvider(
            create: (_) => kIsWeb ? MockAuthService() : AuthService(),
          ),
        ],
        child: const CalmaApp(),
      ),
    );
  } catch (e, stackTrace) {
    print("Erro na inicialização do app: $e");
    print("Stack trace: $stackTrace");

    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            "Erro ao inicializar o aplicativo: $e",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    ));
  }
}

class CalmaApp extends StatelessWidget {
  const CalmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calma AI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Outros estilos...
      ),
      // Rotas do aplicativo
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/meditation': (context) => const MeditationScreen(),
        '/diary': (context) => const DiaryScreen(),
        '/breathing': (context) => const BreathingScreen(),
        '/community': (context) => const CommunityScreen(),
      },
    );
  }
}
