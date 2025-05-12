import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'meditation_screen.dart';
import 'diary_screen.dart';
import 'breathing_screen.dart';
import 'community_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  void _showLoginDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final authService = Provider.of<AuthService>(context, listen: false);
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Impede fechar ao clicar fora
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Login'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                enabled: !isLoading,
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                enabled: !isLoading,
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() {
                        isLoading = true;
                      });

                      // Adicionar um pequeno atraso para simular o processamento
                      await Future.delayed(const Duration(seconds: 1));

                      final success =
                          await authService.loginWithEmailAndPassword(
                        emailController.text,
                        passwordController.text,
                      );

                      // Verificar se o widget ainda está montado
                      if (!context.mounted) return;

                      if (success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Login realizado com sucesso!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        setState(() {
                          isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Falha no login. Verifique suas credenciais.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: const Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calma AI'),
        actions: [
          if (authService.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => authService.logout(),
              tooltip: 'Sair',
            ),
        ],
      ),
      body: authService.isAuthenticated
          ? _buildMainContent(context)
          : _buildLoginContent(context),
    );
  }

  Widget _buildLoginContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Bem-vindo ao Calma AI',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Faça login para acessar recursos de bem-estar mental',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _showLoginDialog(context),
            child: const Text('Entrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Olá, ${authService.userEmail}!',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildFeatureCard(
                context,
                'Meditações',
                Icons.spa,
                Colors.blue,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MeditationScreen()),
                  );
                },
              ),
              _buildFeatureCard(
                context,
                'Diário Emocional',
                Icons.book,
                Colors.green,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DiaryScreen()),
                  );
                },
              ),
              _buildFeatureCard(
                context,
                'Respiração',
                Icons.air,
                Colors.purple,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BreathingScreen()),
                  );
                },
              ),
              _buildFeatureCard(
                context,
                'Comunidade',
                Icons.people,
                Colors.orange,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CommunityScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
