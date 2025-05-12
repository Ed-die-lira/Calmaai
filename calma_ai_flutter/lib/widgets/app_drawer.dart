import 'package:flutter/material.dart';
import '../screens/diagnostic_screen.dart';
import '../screens/home_screen.dart';
import '../screens/meditation_screen.dart';
import '../screens/diary_screen.dart';
import '../screens/breathing_screen.dart';
import '../screens/community_screen.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calma AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Seu app de bem-estar mental',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Início'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.spa),
            title: const Text('Meditações'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/meditation');
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Diário Emocional'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/diary');
            },
          ),
          ListTile(
            leading: const Icon(Icons.air),
            title: const Text('Respiração'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/breathing');
            },
          ),
          ListTile(
            leading: const Icon(Icons.forum),
            title: const Text('Comunidade'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/community');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Diagnóstico'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DiagnosticScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Sair'),
            onTap: () async {
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              await authService.signOut();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
