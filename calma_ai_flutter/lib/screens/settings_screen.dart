import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Perfil'),
            subtitle: Text(authService.userEmail),
            leading: const Icon(Icons.person),
            onTap: () {
              // Abrir tela de perfil
            },
          ),
          SwitchListTile(
            title: const Text('Notificações'),
            subtitle: const Text('Receber lembretes diários'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Modo Escuro'),
            subtitle: const Text('Alterar tema do aplicativo'),
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
              });
            },
          ),
          ListTile(
            title: const Text('Sair'),
            leading: const Icon(Icons.logout),
            onTap: () async {
              await authService.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('Sobre o App'),
            subtitle: Text('Calma AI v1.0.0'),
            leading: Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }
}
