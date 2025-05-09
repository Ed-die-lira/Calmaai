import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

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

void main() async {
  // Garantir que os widgets estejam inicializados
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar Firebase com opções do arquivo de configuração
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase inicializado com sucesso");

    // Inicializar OneSignal (opcional)
    try {
      // Comentado para evitar erros
      // await initOneSignal();
      print("OneSignal inicializado com sucesso");
    } catch (e) {
      print("Erro ao inicializar OneSignal: $e");
    }

    // Executar o aplicativo com o Provider
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthService()),
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

// Inicializar OneSignal para notificações
Future<void> initOneSignal() async {
  // Substitua com sua App ID do OneSignal
  const String oneSignalAppId = 'd11775db-2106-443e-868b-145760ea1579';

  // Inicializar OneSignal com a nova API
  OneSignal.initialize(oneSignalAppId);

  // Solicitar permissão para notificações
  await OneSignal.Notifications.requestPermission(true);
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
