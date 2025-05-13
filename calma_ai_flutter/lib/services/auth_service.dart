import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String uid;
  final String? email;
  final String? displayName;

  User({required this.uid, this.email, this.displayName});
}

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String _userEmail = '';
  String _token = 'dummy_token_12345'; // Token simulado para desenvolvimento

  bool get isAuthenticated => _isAuthenticated;
  String get userEmail => _userEmail;
  Map<String, dynamic> get currentUser => {'email': _userEmail};

  // Método para login com email e senha
  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    try {
      // Simulação de autenticação sem Firebase
      if (email.isNotEmpty && password.isNotEmpty) {
        _isAuthenticated = true;
        _userEmail = email;

        // Salvar estado de autenticação
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
        await prefs.setString('userEmail', email);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Erro no login: $e');
      return false;
    }
  }

  // Método para logout (compatível com ambos os nomes)
  Future<void> logout() async {
    await signOut();
  }

  // Método para logout (nome alternativo)
  Future<void> signOut() async {
    _isAuthenticated = false;
    _userEmail = '';

    // Limpar estado de autenticação
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', false);
    await prefs.remove('userEmail');

    notifyListeners();
  }

  // Verificar se o usuário está autenticado ao iniciar o app
  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _userEmail = prefs.getString('userEmail') ?? '';
    notifyListeners();
  }

  // Obter token de autenticação (simulado)
  Future<String> getToken() async {
    // Em um app real, você renovaria o token se necessário
    return _token;
  }
}
